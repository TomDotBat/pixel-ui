
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

function PANEL:Think()
	local scrw, scrh = ScrW(), ScrH()
	local mousex, mousey = math.Clamp(gui.MouseX(), 1, scrw - 1), math.Clamp(gui.MouseY(), 1, scrh - 1)

	if self.Dragging then
		local x = mousex - self.Dragging[1]
		local y = mousey - self.Dragging[2]

		if self:GetScreenLock() then
			x = math.Clamp(x, 0, scrw - self:GetWide())
			y = math.Clamp(y, 0, scrh - self:GetTall())
		end

		self:SetPos(x, y)
	end

	if self.Sizing then
		local x = mousex - self.Sizing[1]
		local y = mousey - self.Sizing[2]
		local px, py = self:GetPos()

		local screenLock = self:GetScreenLock()
		if x < self.MinWidth then x = self.MinWidth elseif x > scrw - px and screenLock then x = scrw - px end
		if y < self.MinHeight then y = self.MinHeight elseif y > scrh - py and screenLock then y = scrh - py end

		self:SetSize(x, y)
		self:SetCursor("sizenwse")
		return
	end

	local screenX, screenY = self:LocalToScreen(0, 0)

	if self.Hovered and self.Sizable and mousex > (screenX + self:GetWide() - 20) and mousey > (screenY + self:GetTall() - 20) then
		self:SetCursor("sizenwse")
		return
	end

	if self.Hovered and self:GetDraggable() and mousey < (screenY + PIXEL.Scale(30)) then
		self:SetCursor("sizeall")
		return
	end

	self:SetCursor("arrow")

	if self.y < 0 then
		self:SetPos(self.x, 0)
	end
end

function PANEL:OnMousePressed()
	local screenX, screenY = self:LocalToScreen(0, 0)
	local mouseX, mouseY = gui.MouseX(), gui.MouseY()

	if self.Sizable and mouseX > (screenX + self:GetWide() - PIXEL.Scale(30)) and mouseY > (screenY + self:GetTall() - PIXEL.Scale(30)) then
		self.Sizing = {mouseX - self:GetWide(), mouseY - self:GetTall()}
		self:MouseCapture(true)
		return
	end

	if self:GetDraggable() and mouseY < (screenY + PIXEL.Scale(30)) then
		self.Dragging = {mouseX - self.x, mouseY - self.y}
		self:MouseCapture(true)
		return
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture(false)
end

function PANEL:LayoutContent(w, h) end

function PANEL:PerformLayout(w, h)
	local headerH = PIXEL.Scale(30)

	if IsValid(self.CloseButton) then
		local closeSize = headerH * .45
		self.CloseButton:SetSize(closeSize, closeSize)
		self.CloseButton:SetPos(w - closeSize - PIXEL.Scale(6), (headerH - closeSize) / 2)
	end

	local padding = PIXEL.Scale(6)
	self:DockPadding(padding, headerH + padding, padding, padding)

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
		PIXEL.DrawSimpleText(self:GetTitle(), "PIXEL.UI.FrameTitle", x + PIXEL.Scale(12) + iconSize, y + h / 2, PIXEL.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER)
		return
	end

	PIXEL.DrawSimpleText(self:GetTitle(), "PIXEL.UI.FrameTitle", x + PIXEL.Scale(6), y + h / 2, PIXEL.Colors.PrimaryText, nil, TEXT_ALIGN_CENTER)
end

function PANEL:Paint(w, h)
	if not self:GetShadow() then
		PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, PIXEL.Colors.Background)
		self:PaintHeader(0, 0, w, PIXEL.Scale(30))
		return
	end

	local x, y = self:GetPos()
	BSHADOWS.BeginShadow()
	 PIXEL.DrawRoundedBox(PIXEL.Scale(4), x, y, w, h, PIXEL.Colors.Background)
	 self:PaintHeader(x, y, w, PIXEL.Scale(30))
	BSHADOWS.EndShadow(1, 2, 2)
end

vgui.Register("PIXEL.Frame", PANEL, "EditablePanel")