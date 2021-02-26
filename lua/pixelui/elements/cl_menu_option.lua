
local PANEL = {}

AccessorFunc(PANEL, "m_pMenu", "Menu")
AccessorFunc(PANEL, "m_bChecked", "Checked")
AccessorFunc(PANEL, "m_bCheckable", "IsCheckable")

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)

PIXEL.RegisterFont("UI.MenuOption", "Open Sans SemiBold", 18)

function PANEL:Init()
    self:SetTextAlign(TEXT_ALIGN_LEFT)
    self:SetFont("PIXEL.UI.MenuOption")
    self:SetChecked(false)

    self.NormalCol = PIXEL.Colors.Transparent
    self.HoverCol = PIXEL.Colors.Scroller

    self.BackgroundCol = PIXEL.CopyColor(self.NormalCol)
end

function PANEL:SetIcon() end

function PANEL:SetSubMenu(menu)
    self.SubMenu = menu
end

function PANEL:AddSubMenu()
    local subMenu = vgui.Create("PIXEL.Menu", self)
    subMenu:SetVisible(false)
    subMenu:SetParent(self)

    self:SetSubMenu(subMenu)

    return subMenu
end

function PANEL:OnCursorEntered()
    local parent = self.ParentMenu
    if not IsValid(parent) then parent = self:GetParent() end
    if not IsValid(parent) then return end

    if not parent.OpenSubMenu then return end
    parent:OpenSubMenu(self, self.SubMenu)
end

function PANEL:OnCursorExited() end

function PANEL:Paint(w, h)
    self.BackgroundCol = PIXEL.LerpColor(FrameTime() * 12, self.BackgroundCol, self:IsHovered() and self.HoverCol or self.NormalCol)

    surface.SetDrawColor(self.BackgroundCol)
    surface.DrawRect(0, 0, w, h)

    PIXEL.DrawSimpleText(self:GetText(), self:GetFont(), PIXEL.Scale(14), h / 2, PIXEL.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    if not self.SubMenu then return end
    local dropBtnSize = PIXEL.Scale(8)
    PIXEL.DrawImgur(w - dropBtnSize - PIXEL.Scale(6), h / 2 - dropBtnSize / 2, dropBtnSize, dropBtnSize, "gXg3U6X", PIXEL.Colors.PrimaryText)
end

function PANEL:OnPressed(mousecode)
    self.m_MenuClicking = true
end

function PANEL:OnReleased(mousecode)
    if not self.m_MenuClicking and mousecode == MOUSE_LEFT then return end
    self.m_MenuClicking = false
    CloseDermaMenus()
end

function PANEL:DoRightClick()
    if self:GetIsCheckable() then
        self:ToggleCheck()
    end
end

function PANEL:DoClickInternal()
    if self:GetIsCheckable() then
        self:ToggleCheck()
    end

    if not self.m_pMenu then return end
    self.m_pMenu:OptionSelectedInternal(self)
end

function PANEL:ToggleCheck()
    self:SetChecked(not self:GetChecked())
    self:OnChecked(self:GetChecked())
end

function PANEL:OnChecked(enabled) end

function PANEL:CalculateWidth()
    PIXEL.SetFont(self:GetFont())
    return PIXEL.GetTextSize(self:GetText()) + PIXEL.Scale(34)
end

function PANEL:PerformLayout(w, h)
    self:SetSize(math.max(self:CalculateWidth(), self:GetWide()), PIXEL.Scale(32))
end

vgui.Register("PIXEL.MenuOption", PANEL, "PIXEL.Button")

PANEL = {}

AccessorFunc(PANEL, "ConVar", "ConVar")
AccessorFunc(PANEL, "ValueOn", "ValueOn")
AccessorFunc(PANEL, "ValueOff", "ValueOff")

function PANEL:Init()
    self:SetChecked(false)
    self:SetIsCheckable(true)
    self:SetValueOn("1")
    self:SetValueOff("0")
end

function PANEL:Think()
    if not self.ConVar then return end
    self:SetChecked(GetConVar(self.ConVar):GetString() == self.ValueOn)
end

function PANEL:OnChecked(checked)
    if not self.ConVar then return end
    RunConsoleCommand(self.ConVar, checked and self.ValueOn or self.ValueOff)
end

vgui.Register("PIXEL.MenuOptionCVar", PANEL, "PIXEL.MenuOption")