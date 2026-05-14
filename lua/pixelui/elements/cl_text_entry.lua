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

--- PIXEL styled text entry container with integrated label.
---@class PIXEL.TextEntry : Panel
local PANEL = {}

function PANEL:Init()
    self.TextEntry = vgui.Create("PIXEL.TextEntryInternal", self)

    self.PlaceholderTextCol = PIXEL.OffsetColor(PIXEL.Colors.SecondaryText, -110)

    self.DisabledCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 6)
    self.FocusedOutlineCol = PIXEL.Colors.PrimaryText

    self.OutlineCol = PIXEL.OffsetColor(PIXEL.Colors.Scroller, 10)
    self.InnerOutlineCol = PIXEL.CopyColor(PIXEL.Colors.Transparent)
end

function PANEL:PerformLayout(w, h)
    self.TextEntry:Dock(FILL)

    local xPad, yPad = PIXEL.Scale(4), PIXEL.Scale(8)
    self:DockPadding(xPad, yPad, xPad, yPad)
end

function PANEL:Paint(w, h)
    if not self:IsEnabled() then
        PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, self.DisabledCol)
        PIXEL.DrawSimpleText("Disabled", self:GetFont(), PIXEL.Scale(4), h / 2, PIXEL.Colors.SecondaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        return
    end

    if self:GetValue() == "" then
        local placeholderY = self:IsMultiline() and draw.GetFontHeight(self:GetFont()) or h / 2
        PIXEL.DrawSimpleText(self:GetPlaceholderText() or "", self:GetFont(), PIXEL.Scale(10), placeholderY, self.PlaceholderTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local outlineThickness = PIXEL.Scale(1)
    PIXEL.DrawOutlinedRoundedBox(PIXEL.Scale(2), 0, 0, w, h, self.OutlineCol, outlineThickness)

    local col = PIXEL.Colors.Transparent

    if self:IsEditing() then
        col = self.FocusedOutlineCol
    end

    if self.OverrideCol then
        col = self.OverrideCol
    end

    self.InnerOutlineCol = PIXEL.LerpColor(FrameTime() * 8, self.InnerOutlineCol, col)

    PIXEL.DrawOutlinedRoundedBox(PIXEL.Scale(2), outlineThickness, outlineThickness, w - outlineThickness * 2, h - outlineThickness * 2, self.InnerOutlineCol, PIXEL.Scale(1))
end

function PANEL:OnChange() end
function PANEL:OnValueChange(value) end

--- Returns whether text input is enabled.
---@return boolean enabled True when the entry accepts input.
function PANEL:IsEnabled() return self.TextEntry:IsEnabled() end
--- Enables or disables text input.
---@param enabled boolean True to enable input.
function PANEL:SetEnabled(enabled) self.TextEntry:SetEnabled(enabled) end

--- Returns current text value.
---@return string value Current entry text.
function PANEL:GetValue() return self.TextEntry:GetValue() end
--- Sets current text value.
---@param value string New entry text.
function PANEL:SetValue(value) self.TextEntry:SetValue(value) end

--- Returns whether multiline input is enabled.
---@return boolean isMultiline True when multiline mode is enabled.
function PANEL:IsMultiline() return self.TextEntry:IsMultiline() end
--- Enables or disables multiline input.
---@param isMultiline boolean True to enable multiline mode.
function PANEL:SetMultiline(isMultiline) self.TextEntry:SetMultiline(isMultiline) end

--- Returns whether this entry currently has keyboard focus.
---@return boolean isEditing True when focused for typing.
function PANEL:IsEditing() return self.TextEntry:IsEditing() end

--- Returns whether Enter submits single-line input.
---@return boolean allow True when Enter is allowed.
function PANEL:GetEnterAllowed() return self.TextEntry:GetEnterAllowed() end
--- Sets whether Enter submits single-line input.
---@param allow boolean True to allow Enter handling.
function PANEL:SetEnterAllowed(allow) self.TextEntry:SetEnterAllowed(allow) end

--- Returns whether value updates fire while typing.
---@return boolean enabled True when update-on-type is enabled.
function PANEL:GetUpdateOnType() return self.TextEntry:GetUpdateOnType() end
--- Enables or disables update-on-type behavior.
---@param enabled boolean True to update on each text change.
function PANEL:SetUpdateOnType(enabled) self.TextEntry:SetUpdateOnType(enabled) end

--- Returns whether numeric-only input mode is enabled.
---@return boolean enabled True when numeric filtering is enabled.
function PANEL:GetNumeric() return self.TextEntry:GetNumeric() end
--- Enables or disables numeric-only input mode.
---@param enabled boolean True to restrict input to numeric characters.
function PANEL:SetNumeric(enabled) self.TextEntry:SetNumeric(enabled) end

--- Returns whether history navigation is enabled.
---@return boolean enabled True when history is enabled.
function PANEL:GetHistoryEnabled() return self.TextEntry:GetHistoryEnabled() end
--- Enables or disables history navigation.
---@param enabled boolean True to enable history.
function PANEL:SetHistoryEnabled(enabled) self.TextEntry:SetHistoryEnabled(enabled) end

--- Returns whether tabbing is disabled.
---@return boolean disabled True when tabbing is disabled.
function PANEL:GetTabbingDisabled() return self.TextEntry:GetTabbingDisabled() end
--- Enables or disables tabbing behavior.
---@param disabled boolean True to disable tabbing.
function PANEL:SetTabbingDisabled(disabled) self.TextEntry:SetTabbingDisabled(disabled) end

--- Returns placeholder text.
---@return string text Placeholder text.
function PANEL:GetPlaceholderText() return self.TextEntry:GetPlaceholderText() end
--- Sets placeholder text.
---@param text string Placeholder text.
function PANEL:SetPlaceholderText(text) self.TextEntry:SetPlaceholderText(text) end

--- Returns active text font.
---@return string font Font name.
function PANEL:GetFont() return self.TextEntry:GetFont() end
--- Sets active text font.
---@param font string Font name.
function PANEL:SetFont(font) self.TextEntry:SetFontInternal(font) end

--- Returns current value rounded to nearest integer.
---@return number|nil value Parsed integer value.
function PANEL:GetInt() return self.TextEntry:GetInt() end
--- Returns current value parsed as a float.
---@return number|nil value Parsed float value.
function PANEL:GetFloat() return self.TextEntry:GetFloat() end

--- Returns whether this entry currently has keyboard focus.
---@return boolean isEditing True when focused for typing.
function PANEL:IsEditing() return self.TextEntry:IsEditing() end
--- Sets whether editing is allowed.
---@param enabled boolean True to allow editing.
function PANEL:SetEditable(enabled) self.TextEntry:SetEditable(enabled) end

--- Callback used to filter raw character input.
---@param value string Input character.
---@return boolean|nil blocked Return true to block this character.
function PANEL:AllowInput(value) end
--- Callback used to provide autocomplete suggestions.
---@param txt string Current text value.
---@return string[]|nil suggestions Suggested completions.
function PANEL:GetAutoComplete(txt) end

--- Callback fired when a key code is received.
---@param code number Garry's Mod key code.
function PANEL:OnKeyCode(code) end
function PANEL:OnEnter() end

function PANEL:OnGetFocus() end
function PANEL:OnLoseFocus() end

vgui.Register("PIXEL.TextEntry", PANEL, "Panel")
