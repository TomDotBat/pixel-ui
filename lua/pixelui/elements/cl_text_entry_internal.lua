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

--- PIXEL internal text entry (extends TextEntry).
---@class PIXEL.TextEntryInternal : TextEntry
local PANEL = {}

AccessorFunc(PANEL, "m_bAllowEnter", "EnterAllowed", FORCE_BOOL)
AccessorFunc(PANEL, "m_bUpdateOnType", "UpdateOnType", FORCE_BOOL)
AccessorFunc(PANEL, "m_bNumeric", "Numeric", FORCE_BOOL)
AccessorFunc(PANEL, "m_bHistory", "HistoryEnabled", FORCE_BOOL)
AccessorFunc(PANEL, "m_bDisableTabbing", "TabbingDisabled", FORCE_BOOL)
AccessorFunc(PANEL, "m_txtPlaceholder", "PlaceholderText", FORCE_STRING)

Derma_Install_Convar_Functions(PANEL)

PIXEL.RegisterFont("UI.TextEntry", "Open Sans SemiBold", 18)

function PANEL:Init()
    self:SetHistoryEnabled(false)
    self.History = {}
    self.HistoryPos = 0

    self:SetPaintBorderEnabled(false)
    self:SetPaintBackgroundEnabled(false)

    self:SetEnterAllowed(true)
    self:SetUpdateOnType(false)
    self:SetNumeric(false)
    self:SetAllowNonAsciiCharacters(true)

    self:SetTall(PIXEL.Scale(34))

    self.m_bLoseFocusOnClickAway = true

    self:SetCursor("beam")
    self:SetFontInternal(PIXEL.GetRealFont("UI.TextEntry"))
end

--- Returns whether this text entry currently has keyboard focus.
---@return boolean isEditing True when focused for typing.
function PANEL:IsEditing()
    return self == vgui.GetKeyboardFocus()
end

function PANEL:OnKeyCodeTyped(code)
    self:OnKeyCode(code)

    if code == KEY_ENTER and not self:IsMultiline() and self:GetEnterAllowed() then
        if IsValid(self.Menu) then self.Menu:Remove() end

        self:FocusNext()
        self:OnEnter()
        self.HistoryPos = 0
    end

    if self.m_bHistory or IsValid(self.Menu) then
        if code == KEY_UP then
            self.HistoryPos = self.HistoryPos - 1
            self:UpdateFromHistory()
        end

        if code == KEY_DOWN or code == KEY_TAB then
            self.HistoryPos = self.HistoryPos + 1
            self:UpdateFromHistory()
        end
    end
end

--- Forwards key events to the parent text entry panel.
---@param code number Garry's Mod key code.
function PANEL:OnKeyCode(code)
    local parent = self:GetParent()
    if not parent then return end

    if parent.OnKeyCode then parent:OnKeyCode(code) end
end

--- Applies the currently selected history/menu entry into the text field.
function PANEL:UpdateFromHistory()
    if IsValid(self.Menu) then return self:UpdateFromMenu() end
    local pos = self.HistoryPos

    if pos < 0 then
        pos = #self.History
    end

    if pos > #self.History then
        pos = 0
    end

    local text = self.History[pos]
    if not text then
        text = ""
    end

    self:SetText(text)
    self:SetCaretPos(text:len())
    self:OnTextChanged()
    self.HistoryPos = pos
end

--- Applies the currently highlighted autocomplete menu entry.
function PANEL:UpdateFromMenu()
    local pos = self.HistoryPos
    local num = self.Menu:ChildCount()
    self.Menu:ClearHighlights()

    if pos < 0 then
        pos = num
    end

    if pos > num then
        pos = 0
    end

    local item = self.Menu:GetChild(pos)
    if not item then
        self:SetText("")
        self.HistoryPos = pos
        return
    end

    self.Menu:HighlightItem(item)

    local txt = item:GetText()
    self:SetText(txt)
    self:SetCaretPos(txt:len())
    self:OnTextChanged(true)
    self.HistoryPos = pos
end

--- Handles text changes, autocomplete, and value update callbacks.
---@param noMenuRemoval boolean|nil True to preserve the current autocomplete menu.
function PANEL:OnTextChanged(noMenuRemoval)
    self.HistoryPos = 0

    if self:GetUpdateOnType() then
        self:UpdateConvarValue()
        self:OnValueChange(self:GetText())
    end

    if IsValid(self.Menu) and not noMenuRemoval then
        self.Menu:Remove()
    end

    local tab = self:GetAutoComplete(self:GetText())

    if tab then
        self:OpenAutoComplete(tab)
    end

    self:OnChange()
end

function PANEL:OnChange()
    local parent = self:GetParent()
    if not parent then return end

    if parent.OnChange then parent:OnChange() end
end

--- Opens an autocomplete menu with suggestion entries.
---@param tab string[] Suggested completions.
function PANEL:OpenAutoComplete(tab)
    if not tab then return end
    if #tab == 0 then return end
    self.Menu = DermaMenu()

    for k, v in pairs(tab) do
        self.Menu:AddOption(v, function()
            self:SetText(v)
            self:SetCaretPos(v:len())
            self:RequestFocus()
        end)
    end

    local x, y = self:LocalToScreen(0, self:GetTall())
    self.Menu:SetMinimumWidth(self:GetWide())
    self.Menu:Open(x, y, true, self)
    self.Menu:SetPos(x, y)
    self.Menu:SetMaxHeight((ScrH() - y) - 10)
end

function PANEL:Think()
    self:ConVarStringThink()
end

function PANEL:OnEnter()
    self:UpdateConvarValue()
    self:OnValueChange(self:GetText())

    local parent = self:GetParent()
    if not parent then return end

    if parent.OnEnter then parent:OnEnter() end
end

--- Pushes the current text value into the bound convar.
function PANEL:UpdateConvarValue()
    self:ConVarChanged(self:GetValue())
end

function PANEL:Paint(w, h)
    self:DrawTextEntryText(color_white, PIXEL.Colors.Primary, PIXEL.Colors.Primary)
end

--- Sets text value when not actively editing.
---@param value string New text value.
function PANEL:SetValue(value)
    if self:IsEditing() then return end

    self:SetText(value)
    self:OnValueChange(value)
    self:SetCaretPos(self:GetCaretPos())
end

function PANEL:OnValueChange(value)
    local parent = self:GetParent()
    if not parent then return end

    if parent.OnValueChange then parent:OnValueChange(value) end
end

local numericChars = "1234567890.-"
--- Checks whether a character should be blocked by numeric mode.
---@param value string Input character.
---@return boolean blocked True when the character should be blocked.
function PANEL:CheckNumeric(value)
    if not self:GetNumeric() then return false end
    if not string.find(numericChars, value, 1, true) then return true end

    return false
end

--- Filters character input and forwards custom filtering to the parent panel.
---@param value string Input character.
---@return boolean|nil blocked Return true to block this character.
function PANEL:AllowInput(value)
    if self:CheckNumeric(value) then return true end

    local parent = self:GetParent()
    if not parent then return end

    if parent.AllowInput then return parent:AllowInput(value) end
end

--- Enables or disables text entry input handling.
---@param enabled boolean True to allow mouse/keyboard input.
function PANEL:SetEditable(enabled)
    self:SetKeyboardInputEnabled(enabled)
    self:SetMouseInputEnabled(enabled)
end

function PANEL:OnGetFocus()
    hook.Run("OnTextEntryGetFocus", self)

    local parent = self:GetParent()
    if not parent then return end

    if parent.OnGetFocus then parent:OnGetFocus() end
end

function PANEL:OnLoseFocus()
    self:UpdateConvarValue()
    hook.Call("OnTextEntryLoseFocus", nil, self)

    local parent = self:GetParent()
    if not parent then return end

    if parent.OnLoseFocus then parent:OnLoseFocus() end
end

function PANEL:OnMousePressed(mcode)
    self:OnGetFocus()
end

--- Adds a unique value to input history.
---@param txt string Text entry to add.
function PANEL:AddHistory(txt)
    if not txt or txt == "" then return end

    table.RemoveByValue(self.History, txt)
    table.insert(self.History, txt)
end

--- Requests autocomplete suggestions from the parent panel.
---@param txt string Current text value.
---@return string[]|nil suggestions Suggested completions.
function PANEL:GetAutoComplete(txt)
    local parent = self:GetParent()
    if not parent then return end

    if parent.GetAutoComplete then return parent:GetAutoComplete(txt) end
end

--- Returns current value rounded to nearest integer.
---@return number|nil value Parsed integer value.
function PANEL:GetInt()
    local num = tonumber(self:GetText())
    if not num then return end

    return math.floor(num + 0.5)
end

--- Returns current value parsed as a floating point number.
---@return number|nil value Parsed float value.
function PANEL:GetFloat()
    return tonumber(self:GetText())
end

vgui.Register("PIXEL.TextEntryInternal", PANEL, "TextEntry")
