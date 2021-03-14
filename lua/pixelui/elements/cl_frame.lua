
local PANEL = {}

AccessorFunc(PANEL, "Draggable", "Draggable", FORCE_BOOL)
AccessorFunc(PANEL, "Sizable", "Sizable", FORCE_BOOL)
AccessorFunc(PANEL, "MinWidth", "MinWidth", FORCE_NUMBER)
AccessorFunc(PANEL, "MinHeight", "MinHeight", FORCE_NUMBER)
AccessorFunc(PANEL, "ScreenLock", "ScreenLock", FORCE_BOOL)
AccessorFunc(PANEL, "RemoveOnClose", "RemoveOnClose", FORCE_BOOL)

AccessorFunc(PANEL, "Title", "Title", FORCE_STRING)
AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING)
AccessorFunc(PANEL, "Shadow", "Shadow", FORCE_BOOL)

PIXEL.RegisterFont("UI.FrameTitle", "Open Sans Bold", 22)

function PANEL:Init()
	self.CloseButton = vgui.Create("PIXEL.ImgurButton", self)
	self.CloseButton:SetImgurID("z1uAU0b")
	self.CloseButton:SetNormalColor(PIXEL.Colors.PrimaryText)
	self.CloseButton:SetHoverColor(PIXEL.Colors.Negative)
	self.CloseButton:SetClickColor(PIXEL.Colors.Negative)
	self.CloseButton:SetDisabledColor(PIXEL.Colors.DisabledText)

	self.CloseButton.DoClick = function(s)
		self:Close()
	end

	self.ExtraButtons = {}

	self:SetTitle("PIXEL Frame")

	self:SetDraggable(true)
	self:SetScreenLock(true)
	self:SetRemoveOnClose(true)

	local size = PIXEL.Scale(200)
	self:SetMinWidth(size)
	self:SetMinHeight(size)

	local oldMakePopup = self.MakePopup
	function self:MakePopup()
		oldMakePopup(self)
		self:Open()
	end
end

local headerH = PIXEL.Scale(30)
local sizeArea = PIXEL.Scale(20)
local scrW, scrH = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "PIXEL.UI.CacheFrameScreenSizes", function()
	scrW, scrH = ScrW(), ScrH()
	headerH = PIXEL.Scale(30)
	sizeArea = PIXEL.Scale(20)
end)

local clamp = math.Clamp
local getMouseX, getMouseY = gui.MouseX, gui.MouseY

function PANEL:Think()
	if not (self:GetSizable() or self:GetDraggable()) then return end

	local mouseX, mouseY = clamp(getMouseX(), 1, scrW - 1), clamp(getMouseY(), 1, scrH - 1)

	if self.Dragging then
		local x = mouseX - self.Dragging[1]
		local y = mouseY - self.Dragging[2]

		if self:GetScreenLock() then
			x = clamp(x, 0, scrW - self:GetWide())
			y = clamp(y, 0, scrH - self:GetTall())
		end

		self:SetPos(x, y)
	end

	if self.Sizing then
		local x = self.SizingInvertedX and (mouseX + self.Sizing[1]) or (mouseX - self.Sizing[1])
		local y = self.SizingInvertedY and (mouseY + self.Sizing[2]) or (mouseY - self.Sizing[2])

		local selfX, selfY = self:GetPos()
		local screenLock = self:GetScreenLock()

		if x < self.MinWidth then x = self.MinWidth
		elseif x > scrW - selfX and screenLock then x = scrW - selfX end

		if y < self.MinHeight then y = self.MinHeight
		elseif y > scrH - selfY and screenLock then y = scrH - selfY end

		self:SetSize(x, y)
		self:SetCursor(self.SizingCursor)

		return
	end

	if self.Hovered then
		local localMouseX, localMouseY = self:ScreenToLocal(mouseX, mouseY)

		if localMouseX < 0 or localMouseY < 0 then return end
		if localMouseX > self:GetWide() or localMouseY > self:GetTall() then return end

		if self:GetSizable() then
			if localMouseX < sizeArea then --Left
				if localMouseY < sizeArea then --Top
					self:SetCursor("sizenwse")
					self.SizingInvertedX = true
					self.SizingInvertedY = true
					return
				elseif localMouseY > (self:GetTall() - sizeArea) then
					self:SetCursor("sizenesw")
					self.SizingInvertedX = true
					return
				end
			elseif localMouseX > (self:GetWide() - sizeArea) then --Right
				if localMouseY < sizeArea then --Top
					self:SetCursor("sizenesw")
					self.SizingInvertedY = true
					return
				elseif localMouseY > (self:GetTall() - sizeArea) then
					self:SetCursor("sizenwse")
					return
				end
			end
		end

		if self:GetDraggable() and localMouseY < headerH then
			self:SetCursor("sizeall")
			return
		end
	end

	self:SetCursor("arrow")

	if self.y < 0 then
		self:SetPos(self.x, 0)
	end
end

function PANEL:OnMousePressed()
	local mouseX, mouseY = getMouseX(), getMouseY()
	local localMouseX, localMouseY = self:ScreenToLocal(mouseX, mouseY)

	if localMouseX < 0 or localMouseY < 0 then print("no") return end
	if localMouseX > self:GetWide() or localMouseY > self:GetTall() then print("no2") return end

	if self:GetSizable() then
		if localMouseX < sizeArea then --Left
			if localMouseY < sizeArea then --Top
				self.SizingCursor = "sizenwse"
				self.Sizing = {mouseX - self:GetWide(), mouseY - self:GetTall()}
				self:MouseCapture(true)
				return
			elseif localMouseY > (self:GetTall() - sizeArea) then
				self.SizingCursor = "sizenesw"
				self.Sizing = {mouseX - self:GetWide(), mouseY - self:GetTall()}
				self:MouseCapture(true)
				return
			end
		elseif localMouseX > (self:GetWide() - sizeArea) then --Right
			if localMouseY < sizeArea then --Top
				self.SizingCursor = "sizenesw"
				self.Sizing = {mouseX - self:GetWide(), mouseY - self:GetTall()}
				self:MouseCapture(true)
				return
			elseif localMouseY > (self:GetTall() - sizeArea) then
				self.SizingCursor = "sizenwse"
				self.Sizing = {mouseX - self:GetWide(), mouseY - self:GetTall()}
				self:MouseCapture(true)
				return
			end
		end
	end

	if self:GetDraggable() and localMouseY < headerH then
		self.Dragging = {mouseX - self.x, mouseY - self.y}
		self:MouseCapture(true)
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self.Sizing = nil
	self.SizingInvertedX = nil
	self.SizingInvertedY = nil
	self.SizingCursor = nil
	self:MouseCapture(false)
end

function PANEL:CreateSidebar(defaultItem, imgurID, imgurScale, imgurYOffset, buttonYOffset)
	if IsValid(self.SideBar) then return end
	self.SideBar = vgui.Create("PIXEL.Sidebar", self)

	if defaultItem then
		timer.Simple(0, function()
			if not IsValid(self.SideBar) then return end
			self.SideBar:SelectItem(defaultItem)
		end)
	end

	if imgurID then self.SideBar:SetImgurID(imgurID) end
	if imgurScale then self.SideBar:SetImgurScale(imgurScale) end
	if imgurYOffset then self.SideBar:SetImgurOffset(imgurYOffset) end
	if buttonYOffset then self.SideBar:SetButtonOffset(buttonYOffset) end

	return self.SideBar
end

function PANEL:AddHeaderButton(elem, size)
	elem.HeaderIconSize = size or .45
	return table.insert(self.ExtraButtons, elem)
end

function PANEL:LayoutContent(w, h) end

function PANEL:PerformLayout(w, h)
	local btnPad = PIXEL.Scale(6)
	local btnSpacing = PIXEL.Scale(6)

	if IsValid(self.CloseButton) then
		local btnSize = headerH * .45
		self.CloseButton:SetSize(btnSize, btnSize)
		self.CloseButton:SetPos(w - btnSize - btnPad, (headerH - btnSize) / 2)

		btnPad = btnPad + btnSize + btnSpacing
	end

	for _, btn in ipairs(self.ExtraButtons) do
		local btnSize = headerH * btn.HeaderIconSize
		btn:SetSize(btnSize, btnSize)
		btn:SetPos(w - btnSize - btnPad, (headerH - btnSize) / 2)
		btnPad = btnPad + btnSize + btnSpacing
	end

	if IsValid(self.SideBar) then
		self.SideBar:SetPos(0, headerH)
		self.SideBar:SetSize(PIXEL.Scale(200), h - headerH)
	end

	local padding = PIXEL.Scale(6)
	self:DockPadding(self.SideBar and PIXEL.Scale(200) + padding or padding, headerH + padding, padding, padding)

	self:LayoutContent(w, h)
end

function PANEL:Open()
	self:SetAlpha(0)
	self:SetVisible(true)
	self:AlphaTo(255, .1, 0)
end

function PANEL:Close()
	self:AlphaTo(0, .1, 0, function(anim, pnl)
		if not IsValid(pnl) then return end
		pnl:SetVisible(false)
		pnl:OnClose()
		if pnl:GetRemoveOnClose() then pnl:Remove() end
	end)
end

function PANEL:OnClose() end

function PANEL:PaintHeader(x, y, w, h)
	PIXEL.DrawRoundedBoxEx(PIXEL.Scale(6), x, y, w, h, PIXEL.Colors.Header, true, true)

	local imgurID = self:GetImgurID()
	if imgurID then
		local iconSize = h * .6
		PIXEL.DrawImgur(PIXEL.Scale(6), x + (h - iconSize) / 2, y + iconSize, iconSize, imgurID, color_white)
		PIXEL.DrawSimpleText(self:GetTitle(), "UI.FrameTitle", x + PIXEL.Scale(12) + iconSize, y + h / 2, PIXEL.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER)
		return
	end

	PIXEL.DrawSimpleText(self:GetTitle(), "UI.FrameTitle", x + PIXEL.Scale(6), y + h / 2, PIXEL.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER)
end

function PANEL:Paint(w, h)
	if not self:GetShadow() then
		PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, PIXEL.Colors.Background)
		self:PaintHeader(0, 0, w, PIXEL.Scale(30))
		return
	end

	if not self.ShadowID then
		self.ShadowID = self:GetTitle() .. CurTime()
	end

	local x, y = self:GetPos()
	PIXEL.BShadows.BeginShadow(self.ShadowID, 0, 0, w, h)
	 PIXEL.DrawRoundedBox(PIXEL.Scale(4), x, y, w, h, PIXEL.Colors.Background)
	 self:PaintHeader(x, y, w, PIXEL.Scale(30))
	PIXEL.BShadows.EndShadow(self.ShadowID, x, y, 1, 2, 2)
end

vgui.Register("PIXEL.Frame", PANEL, "EditablePanel")