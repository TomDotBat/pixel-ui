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

--- PIXEL text entry with validation message.
---@class PIXEL.ValidatedTextEntry : Panel
local PANEL = {}

function PANEL:Init()
    self.TextEntry = vgui.Create("PIXEL.TextEntry", self)
    self.Message = vgui.Create("PIXEL.Label", self)
    self.Message:SetText("")

    self.TextEntry.OnChange = function(s)
        local text = s:GetValue()
        if text == "" then
            self.Message:SetText("")
            s.OverrideCol = nil
            return
        end

        local valid, message = self:IsTextValid(text)

        self:OnValidate(valid, message)

        if valid then
            self.Message:SetText(message or "")
            self.Message:SetTextColor(PIXEL.Colors.Positive)

            s.OverrideCol = PIXEL.Colors.Positive
        else
            self.Message:SetText(message or "")
            self.Message:SetTextColor(PIXEL.Colors.Negative)

            s.OverrideCol = PIXEL.Colors.Negative
        end
    end
end

--- Validates the current text value.
---@param text string Input text to validate.
---@return boolean valid Whether the input is valid.
---@return string? message Validation feedback message.
function PANEL:IsTextValid(text)
    if text == "test" then
        return true
    end

    return false, "This is invalid text lol"
end

--- Callback fired after validation.
---@param valid boolean Whether the input is valid.
---@param message string|nil Validation feedback message.
function PANEL:OnValidate(valid, message) end

function PANEL:PerformLayout(w, h)
    self.TextEntry:SetTall(PIXEL.Scale(34))
    self.TextEntry:Dock(TOP)

    self.Message:Dock(TOP)
    self.Message:DockMargin(PIXEL.Scale(4), PIXEL.Scale(5), 0, 0)

    self:SizeToChildren(false, true)
end

--- Sets the text entry value.
---@param text string Input text.
function PANEL:SetValue(text) self.TextEntry:SetValue(text) end
--- Gets the text entry value.
---@return string value Current input value.
function PANEL:GetValue() return self.TextEntry:GetValue() end

--- Sets placeholder text for the input.
---@param text string Placeholder text.
function PANEL:SetPlaceholderText(text) self.TextEntry:SetPlaceholderText(text) end
--- Gets placeholder text for the input.
---@return string text Current placeholder text.
function PANEL:GetPlaceholderText() return self.TextEntry:GetPlaceholderText() end

vgui.Register("PIXEL.ValidatedTextEntry", PANEL, "Panel")
