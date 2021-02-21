
local PANEL = {}

AccessorFunc(PANEL, "m_bBorder", "DrawBorder")
AccessorFunc(PANEL, "m_bDeleteSelf", "DeleteSelf")
AccessorFunc(PANEL, "m_iMinimumWidth", "MinimumWidth")
AccessorFunc(PANEL, "m_bDrawColumn", "DrawColumn")
AccessorFunc(PANEL, "m_iMaxHeight", "MaxHeight")
AccessorFunc(PANEL, "m_pOpenSubMenu", "OpenSubMenu")

function PANEL:Init()
    self:SetIsMenu(true)
    self:SetDrawBorder(true)
    self:SetPaintBackground(true)
    self:SetMinimumWidth(PIXEL.Scale(100))
    self:SetDrawOnTop(true)
    self:SetMaxHeight(ScrH() * 0.3)
    self:SetDeleteSelf(true)
    self:SetBarDockShouldOffset(true)

    self:SetPadding(0)

    self.BackgroundCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 10)

    RegisterDermaMenuForClose(self)
end

function PANEL:AddPanel(pnl)
    self:AddItem(pnl)
    pnl.ParentMenu = self
end

function PANEL:AddOption(strText, funcFunction)
    local pnl = vgui.Create("PIXEL.MenuOption", self)
    pnl:SetMenu(self)
    pnl:SetText(strText)
    if funcFunction then pnl.DoClick = funcFunction end

    self:AddPanel(pnl)

    return pnl
end

function PANEL:AddCVar(strText, convar, on, off, funcFunction)
    local pnl = vgui.Create("PIXEL.MenuOptionCVar", self)
    pnl:SetMenu(self)
    pnl:SetText(strText)
    if funcFunction then pnl.DoClick = funcFunction end

    pnl:SetConVar(convar)
    pnl:SetValueOn(on)
    pnl:SetValueOff(off)

    self:AddPanel(pnl)

    return pnl
end

function PANEL:AddSpacer(text, func)
    local pnl = vgui.Create("Panel", self)

    pnl.Paint = function(p, w, h)
        surface.SetDrawColor(PIXEL.Colors.PrimaryText)
        surface.DrawRect(0, 0, w, h)
    end

    pnl:SetTall(PIXEL.Scale(2))
    self:AddPanel(pnl)

    return pnl
end

function PANEL:AddSubMenu(strText, funcFunction)
    local pnl = vgui.Create("PIXEL.MenuOption", self)
    local subMenu = pnl:AddSubMenu(strText, funcFunction)

    pnl:SetText(strText)
    if funcFunction then pnl.DoClick = funcFunction end

    self:AddPanel(pnl)

    return subMenu, pnl
end

function PANEL:Hide()
    local openmenu = self:GetOpenSubMenu()
    if openmenu then
        openmenu:Hide()
    end

    self:SetVisible(false)
    self:SetOpenSubMenu(nil)
end

function PANEL:OpenSubMenu(item, menu)
    local openmenu = self:GetOpenSubMenu()
    if IsValid(openmenu) and openmenu:IsVisible() then
        if menu and openmenu == menu then return end

        self:CloseSubMenu(openmenu)
    end

    if not IsValid(menu) then return end

    local x, y = item:LocalToScreen(self:GetWide(), 0)
    menu:Open(x, y, false, item)

    self:SetOpenSubMenu(menu)
end

function PANEL:CloseSubMenu(menu)
    menu:Hide()
    self:SetOpenSubMenu(nil)
end

function PANEL:Paint(w, h)
    PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, self.BackgroundCol)
end

function PANEL:ChildCount()
    return #self:GetCanvas():GetChildren()
end

function PANEL:GetChild(num)
    return self:GetCanvas():GetChildren()[num]
end

function PANEL:LayoutContent(w, h)
    w = self:GetMinimumWidth()

    local children = self:GetCanvas():GetChildren()
    for k, pnl in pairs(children) do
        pnl:InvalidateLayout(true)
        w = math.max(w, pnl:GetWide())
    end

    self:SetWide(w)

    local y = 0
    for k, pnl in pairs(children) do
        pnl:SetWide(w)
        pnl:SetPos(0, y)
        pnl:InvalidateLayout(true)

        y = y + pnl:GetTall()
    end

    y = math.min(y, self:GetMaxHeight())

    self:SetTall(y)

    local overlap = select(2, self:LocalToScreen(0, y)) - ScrH()
    if overlap > 0 then
        self:SetPos(self:GetPos(), select(2, self:GetPos()) - overlap)
    end
end

function PANEL:Open(x, y, skipanimation, ownerpanel)
    RegisterDermaMenuForClose(self)

    local maunal = x and y
    x = x or gui.MouseX()
    y = y or gui.MouseY()

    local ownerHeight = 0
    if ownerpanel then ownerHeight = ownerpanel:GetTall() end

    self:InvalidateLayout(true)

    local w, h = self:GetWide(), self:GetTall()

    self:SetSize(w, h)

    if y + h > ScrH() then y = ((maunal and ScrH()) or (y + ownerHeight)) - h end
    if x + w > ScrW() then x = ((maunal and ScrW()) or x) - w end
    if y < 1 then y = 1 end
    if x < 1 then x = 1 end

    self:SetPos(x, y)

    self:MakePopup()
    self:SetVisible(true)
    self:SetKeyboardInputEnabled(false)
end

function PANEL:OptionSelectedInternal(option)
    self:OptionSelected(option, option:GetText())
end

function PANEL:OptionSelected(option, text) end

function PANEL:ClearHighlights()
    for k, pnl in pairs(self:GetCanvas():GetChildren()) do
        pnl.Highlight = nil
    end
end

function PANEL:HighlightItem(item)
    for k, pnl in pairs(self:GetCanvas():GetChildren()) do
        if pnl == item then
            pnl.Highlight = true
        end
    end
end

vgui.Register("PIXEL.Menu", PANEL, "PIXEL.ScrollPanel")