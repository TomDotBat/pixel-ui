
local PANEL = {}

AccessorFunc(PANEL, "m_sText", "Text")
AccessorFunc(PANEL, "m_pPropertySheet", "PropertySheet")
AccessorFunc(PANEL, "m_pPanel", "Panel")

PIXEL.RegisterFont("UI.Tab", "Open Sans Bold", 16)

function PANEL:Init()
	self.BackgroundCol = PIXEL.OffsetColor(PIXEL.Colors.Background, -4)
	self.SelectedCol = PIXEL.Colors.Primary
	self.UnselectedTextCol = PIXEL.Colors.SecondaryText
	self.SelectedTextCol = PIXEL.Colors.PrimaryText

	self.Color = PIXEL.CopyColor(self.BackgroundCol)
	self.TextColor = PIXEL.CopyColor(self.UnselectedTextCol)
end

function PANEL:Setup(text, propertySheet, panel)
	self:SetText(text)
	self:SetPropertySheet(propertySheet)
	self:SetPanel(panel)

	PIXEL.SetFont("UI.Tab")
	self:SetWide(PIXEL.GetTextSize(text) + PIXEL.Scale(16))
end

function PANEL:IsActive()
	return self:GetPropertySheet():GetActiveTab() == self
end

function PANEL:DoClick()
	self:GetPropertySheet():SetActiveTab(self)
end

function PANEL:GetTabHeight()
	return PIXEL.Scale(24)
end

function PANEL:DragHoverClick(hoverTime)
	self:DoClick()
end

function PANEL:DoRightClick()
	if not IsValid(self:GetPropertySheet()) then return end

	local tabs = vgui.Create("PIXEL.Menu", self)

	for k, v in pairs(self:GetPropertySheet().Items) do
		if not v or not IsValid(v.Tab) or not v.Tab:IsVisible() then continue end

		tabs:AddOption(v.Tab:GetText(), function()
			if not v or not IsValid(v.Tab) or not IsValid(self:GetPropertySheet()) or not IsValid(self:GetPropertySheet().tabScroller) then return end
			v.Tab:DoClick()
			self:GetPropertySheet().tabScroller:ScrollToChild(v.Tab)
		end)
	end

	tabs:Open()
end

function PANEL:Paint(w, h)
	self.Color = PIXEL.LerpColor(FrameTime() * 12, self.Color, (self:IsActive() or self:IsHovered()) and self.SelectedCol or self.BackgroundCol)
	self.TextColor = PIXEL.LerpColor(FrameTime() * 12, self.TextColor, (self:IsActive() or self:IsHovered()) and self.SelectedTextCol or self.UnselectedTextCol)

	PIXEL.DrawRoundedBoxEx(PIXEL.Scale(6), 0, 0, w, h, self.Color, true, true)
	PIXEL.DrawSimpleText(self:GetText(), "PIXEL.UI.Tab", w * .5, h * .5, self.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.Tab", PANEL, "PIXEL.Button")


PANEL = {}

AccessorFunc(PANEL, "m_pActiveTab", "ActiveTab")
AccessorFunc(PANEL, "m_iPadding", "Padding")
AccessorFunc(PANEL, "m_fFadeTime", "FadeTime")

function PANEL:Init()
	self.tabScroller = vgui.Create("DHorizontalScroller", self)
	self.tabScroller:SetOverlap(PIXEL.Scale(5))
	self.tabScroller:Dock(TOP)
	self.tabScroller:DockMargin(PIXEL.Scale(3), 0, PIXEL.Scale(3), 0)

	self:SetFadeTime(0.1)
	self:SetPadding(PIXEL.Scale(8))

	self.animFade = Derma_Anim("Fade", self, self.CrossFade)

	self.Items = {}

	self.BackgroundCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 2)
end

function PANEL:AddSheet(label, panel, material, noStretchX, noStretchY, tooltip)
	if not IsValid(panel) then
		ErrorNoHalt("PIXEL.PropertySheet:AddSheet tried to add invalid panel!")
		debug.Trace()
		return
	end

	local sheet = {}

	sheet.Name = label

	sheet.Tab = vgui.Create("PIXEL.Tab", self)
	sheet.Tab:SetTooltip(tooltip)
	sheet.Tab:Setup(label, self, panel, material)

	sheet.Panel = panel
	sheet.Panel.NoStretchX = noStretchX
	sheet.Panel.NoStretchY = noStretchY
	sheet.Panel:SetPos(self:GetPadding(), PIXEL.Scale(24) + self:GetPadding())
	sheet.Panel:SetVisible(false)

	panel:SetParent(self)

	table.insert(self.Items, sheet)

	if not self:GetActiveTab() then
		self:SetActiveTab(sheet.Tab)
		sheet.Panel:SetVisible(true)
	end

	self.tabScroller:AddPanel(sheet.Tab)

	return sheet
end

function PANEL:SetActiveTab(active)
	if not IsValid(active) or self.m_pActiveTab == active then return end

	if IsValid(self.m_pActiveTab) then
		self:OnActiveTabChanged(self.m_pActiveTab, active)

		if self:GetFadeTime() > 0 then
			self.animFade:Start(self:GetFadeTime(), {OldTab = self.m_pActiveTab, NewTab = active})
		else
			self.m_pActiveTab:GetPanel():SetVisible(false)
		end
	end

	self.m_pActiveTab = active
	self:InvalidateLayout()
end

function PANEL:OnActiveTabChanged(old, new) end

function PANEL:Think()
	self.animFade:Run()
end

function PANEL:GetItems()
	return self.Items
end

function PANEL:CrossFade(anim, delta, data)
	if not data or not IsValid(data.OldTab) or not IsValid(data.NewTab) then return end

	local old = data.OldTab:GetPanel()
	local new = data.NewTab:GetPanel()

	if not IsValid(old) and not IsValid(new) then return end

	if anim.Finished then
		if IsValid(old) then
			old:SetAlpha(255)
			old:SetZPos(0)
			old:SetVisible(false)
		end

		if IsValid(new) then
			new:SetAlpha(255)
			new:SetZPos(0)
			new:SetVisible(true)
		end

		return
	end

	if anim.Started then
		if IsValid(old) then
			old:SetAlpha(255)
			old:SetZPos(0)
		end

		if IsValid(new) then
			new:SetAlpha(0)
			new:SetZPos(1)
		end
	end

	if IsValid(old) then
		old:SetVisible(true)
		if not IsValid(new) then old:SetAlpha(255 * (1 - delta)) end
	end

	if IsValid(new) then
		new:SetVisible(true)
		new:SetAlpha(255 * delta)
	end
end

function PANEL:PerformLayout()
	local activeTab = self:GetActiveTab()
	local padding = self:GetPadding()

	if not IsValid(activeTab) then return end

	activeTab:InvalidateLayout(true)

	self.tabScroller:SetTall(activeTab:GetTall())

	local activePanel = activeTab:GetPanel()

	for k, v in pairs(self.Items) do
		if v.Tab:GetPanel() == activePanel then
			if IsValid(v.Tab:GetPanel()) then v.Tab:GetPanel():SetVisible(true) end
			v.Tab:SetZPos(100)
		else
			if IsValid(v.Tab:GetPanel()) then v.Tab:GetPanel():SetVisible(false) end
			v.Tab:SetZPos(1)
		end
	end

	if IsValid(activePanel) then
		if not activePanel.NoStretchX then
			activePanel:SetWide(self:GetWide() - padding * 2)
		else
			activePanel:CenterHorizontal()
		end

		if not activePanel.NoStretchY then
			local _, y = activePanel:GetPos()
			activePanel:SetTall(self:GetTall() - y - padding)
		else
			activePanel:CenterVertical()
		end

		activePanel:InvalidateLayout()
	end

	self.animFade:Run()
end

function PANEL:SizeToContentWidth()
	local wide = 0

	for k, v in pairs(self.Items) do
		if IsValid(v.Panel) then
			v.Panel:InvalidateLayout(true)
			wide = math.max(wide, v.Panel:GetWide() + self:GetPadding() * 2)
		end
	end

	self:SetWide(wide)
end

function PANEL:SwitchToName(name)
	for k, v in pairs(self.Items) do
		if v.Name == name then
			v.Tab:DoClick()
			return true
		end
	end

	return false
end

function PANEL:CloseTab(tab, removePanelToo)
	for k, v in pairs(self.Items) do
		if v.Tab ~= tab then continue end
		table.remove(self.Items, k)
	end

	for k, v in pairs(self.tabScroller.Panels) do
		if v ~= tab then continue end
		table.remove(self.tabScroller.Panels, k)
	end

	self.tabScroller:InvalidateLayout(true)

	if tab == self:GetActiveTab() then
		self.m_pActiveTab = self.Items[#self.Items].Tab
	end

	local pnl = tab:GetPanel()
	if removePanelToo then
		pnl:Remove()
	end

	tab:Remove()

	self:InvalidateLayout(true)

	return pnl
end

function PANEL:Paint(w, h)
	local activeTab = self:GetActiveTab()
	local offset = activeTab and activeTab:GetTall() or 0

	PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, offset, w, h - offset, self.BackgroundCol)
end

vgui.Register("PIXEL.PropertySheet", PANEL, "Panel")