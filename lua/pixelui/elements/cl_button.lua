
local PANEL = {}

AccessorFunc(PANEL, "IsToggle", "IsToggle", FORCE_BOOL)
AccessorFunc(PANEL, "Toggle", "Toggle", FORCE_BOOL)

function PANEL:Init()
    self:SetIsToggle(false)
    self:SetToggle(false)
    self:SetMouseInputEnabled(true)

    self:SetCursor("hand")

    local btnSize = PIXEL.Scale(30)
    self:SetSize(btnSize, btnSize)

    self.NormalCol = PIXEL.CopyColor(PIXEL.Colors.Primary)
    self.HoverCol = PIXEL.OffsetColor(self.NormalCol, -15)
    self.ClickedCol = PIXEL.OffsetColor(self.NormalCol, 15)
    self.DisabledCol = PIXEL.CopyColor(PIXEL.Colors.Disabled)

    self.BackgroundCol = self.NormalCol
end

function PANEL:DoToggle()
    if not self:GetIsToggle() then return end

    self:SetToggle(not self:GetToggle())
    self:OnToggled(self:GetToggle())
end

local localPly
function PANEL:OnMousePressed(mouseCode)
    if not self:IsEnabled() then return end

    if not localPly then
        localPly = LocalPlayer()
    end

    if self:IsSelectable() and mouseCode == MOUSE_LEFT and (input.IsShiftDown() or input.IsControlDown()) and not (localPly:KeyDown(IN_FORWARD) or localPly:KeyDown(IN_BACK) or localPly:KeyDown(IN_MOVELEFT) or localPly:KeyDown(IN_MOVERIGHT)) then
        return self:StartBoxSelection()
    end

    self:MouseCapture(true)
    self.Depressed = true
    self:OnPressed(mouseCode)

    self:DragMousePress(mouseCode)
end

function PANEL:OnMouseReleased(mouseCode)
    self:MouseCapture(false)

    if not self:IsEnabled() then return end
    if not self.Depressed and dragndrop.m_DraggingMain ~= self then return end

    if self.Depressed then
        self.Depressed = nil
        self:OnReleased(mouseCode)
    end

    if self:DragMouseRelease(mouseCode) then
        return
    end

    if self:IsSelectable() and mouseCode == MOUSE_LEFT then
        local canvas = self:GetSelectionCanvas()
        if canvas then
            canvas:UnselectAll()
        end
    end

    if not self.Hovered then return end

    self.Depressed = true

    if mouseCode == MOUSE_RIGHT then
        self:DoRightClick()
    elseif mouseCode == MOUSE_LEFT then
        self:DoClick()
    elseif mouseCode == MOUSE_MIDDLE then
        self:DoMiddleClick()
    end

    self.Depressed = nil
end

function PANEL:PaintExtra(w, h) end

function PANEL:Paint(w, h)
    --if not self:IsEnabled() then
    --    PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, self.DisabledCol)
    --    self:PaintExtra(w, h)
    --    return
    --end
--
    --local bgCol = self.BackgroundCol
--
    --if self:IsDown() or self:GetToggle() then
    --    bgCol = self.ClickedCol
    --elseif self:IsHovered() then
    --    bgCol = self.HoverCol
    --end
--
    --self.BackgroundCol = PIXEL.LerpColor(FrameTime() * 12, self.BackgroundCol, bgCol)
--
    --PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, self.BackgroundCol)
--
    --self:PaintExtra(w, h)
end

function PANEL:IsDown() return self.Depressed end
function PANEL:OnPressed(mouseCode) end
function PANEL:OnReleased(mouseCode) end
function PANEL:OnToggled(enabled) end
function PANEL:DoClick() self:DoToggle() end
function PANEL:DoRightClick() end
function PANEL:DoMiddleClick() end

vgui.Register("PIXEL.Button", PANEL, "Panel")