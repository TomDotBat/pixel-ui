--[[
	PIXEL UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

--- PIXEL context menu panel.
---@class PIXEL.Menu : PIXEL.ScrollPanel
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

--- Adds an existing panel to the menu canvas.
---@param pnl Panel Panel instance to insert.
function PANEL:AddPanel(pnl)
    self:AddItem(pnl)
    pnl.ParentMenu = self
end

--- Creates and adds a standard clickable option.
---@param strText string Option label.
---@param funcFunction fun()|nil Callback run when clicked.
---@return PIXEL.MenuOption option Created option panel.
function PANEL:AddOption(strText, funcFunction)
    local pnl = vgui.Create("PIXEL.MenuOption", self)
    pnl:SetMenu(self)
    pnl:SetText(strText)
    if funcFunction then pnl.DoClick = funcFunction end

    self:AddPanel(pnl)

    return pnl
end

--- Creates and adds a cvar-bound option.
---@param strText string Option label.
---@param convar string Console variable name.
---@param on any Value used for the enabled state.
---@param off any Value used for the disabled state.
---@param funcFunction fun()|nil Optional click callback.
---@return PIXEL.MenuOptionCVar option Created cvar option panel.
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

--- Adds a spacer panel between menu options.
---@param text string|nil Unused legacy parameter.
---@param func fun|nil Unused legacy parameter.
---@return Panel spacer Created spacer panel.
function PANEL:AddSpacer(text, func)
    local pnl = vgui.Create("Panel", self)

    local spacerCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 6)
    pnl.Paint = function(p, w, h)
        surface.SetDrawColor(spacerCol)
        surface.DrawRect(0, 0, w, h)
    end

    pnl:SetTall(PIXEL.Scale(3))
    self:AddPanel(pnl)

    return pnl
end

--- Creates a submenu option and returns the submenu panel.
---@param strText string Option label.
---@param funcFunction fun()|nil Optional click callback.
---@return PIXEL.Menu subMenu Created submenu.
---@return PIXEL.MenuOption option Parent option panel.
function PANEL:AddSubMenu(strText, funcFunction)
    local pnl = vgui.Create("PIXEL.MenuOption", self)
    local subMenu = pnl:AddSubMenu(strText, funcFunction)

    pnl:SetText(strText)
    if funcFunction then pnl.DoClick = funcFunction end

    self:AddPanel(pnl)

    return subMenu, pnl
end

--- Hides this menu and any open submenu.
function PANEL:Hide()
    local openmenu = self:GetOpenSubMenu()
    if openmenu then
        openmenu:Hide()
    end

    self:SetVisible(false)
    self:SetOpenSubMenu(nil)
end

--- Opens a submenu anchored to a menu item.
---@param item Panel Parent menu option.
---@param menu PIXEL.Menu|nil Submenu to open.
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

--- Closes the provided submenu.
---@param menu PIXEL.Menu Submenu to close.
function PANEL:CloseSubMenu(menu)
    menu:Hide()
    self:SetOpenSubMenu(nil)
end

function PANEL:Paint(w, h)
    PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, self.BackgroundCol)
end

--- Returns the number of menu children.
---@return number count Child panel count.
function PANEL:ChildCount()
    return #self:GetCanvas():GetChildren()
end

--- Returns a child panel by 1-based index.
---@param num number Child index.
---@return Panel|nil child Child panel.
function PANEL:GetChild(num)
    return self:GetCanvas():GetChildren()[num]
end

--- Lays out menu children and clamps menu height.
---@param w number Panel width.
---@param h number Panel height.
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

--- Opens the menu at screen coordinates.
---@param x number|nil Screen X coordinate.
---@param y number|nil Screen Y coordinate.
---@param skipanimation boolean|nil Unused legacy parameter.
---@param ownerpanel Panel|nil Optional panel the menu is attached to.
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

--- Internal selection handler for option panels.
---@param option PIXEL.MenuOption Selected option.
function PANEL:OptionSelectedInternal(option)
    self:OptionSelected(option, option:GetText())
end

--- Called when an option is selected.
---@param option PIXEL.MenuOption Selected option.
---@param text string Selected option text.
function PANEL:OptionSelected(option, text) end

--- Clears highlight state from all options.
function PANEL:ClearHighlights()
    for k, pnl in pairs(self:GetCanvas():GetChildren()) do
        pnl.Highlight = nil
    end
end

--- Highlights a specific menu item.
---@param item Panel Item panel to highlight.
function PANEL:HighlightItem(item)
    for k, pnl in pairs(self:GetCanvas():GetChildren()) do
        if pnl == item then
            pnl.Highlight = true
        end
    end
end

vgui.Register("PIXEL.Menu", PANEL, "PIXEL.ScrollPanel")
