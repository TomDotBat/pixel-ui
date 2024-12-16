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

function PANEL:IsEnabled() return self.TextEntry:IsEnabled() end
function PANEL:SetEnabled(enabled) self.TextEntry:SetEnabled(enabled) end

function PANEL:GetValue() return self.TextEntry:GetValue() end
function PANEL:SetValue(value) self.TextEntry:SetValue(value) end

function PANEL:IsMultiline() return self.TextEntry:IsMultiline() end
function PANEL:SetMultiline(isMultiline) self.TextEntry:SetMultiline(isMultiline) end

function PANEL:IsEditing() return self.TextEntry:IsEditing() end

function PANEL:GetEnterAllowed() return self.TextEntry:GetEnterAllowed() end
function PANEL:SetEnterAllowed(allow) self.TextEntry:SetEnterAllowed(allow) end

function PANEL:GetUpdateOnType() return self.TextEntry:GetUpdateOnType() end
function PANEL:SetUpdateOnType(enabled) self.TextEntry:SetUpdateOnType(enabled) end

function PANEL:GetNumeric() return self.TextEntry:GetNumeric() end
function PANEL:SetNumeric(enabled) self.TextEntry:SetNumeric(enabled) end

function PANEL:GetHistoryEnabled() return self.TextEntry:GetHistoryEnabled() end
function PANEL:SetHistoryEnabled(enabled) self.TextEntry:SetHistoryEnabled(enabled) end

function PANEL:GetTabbingDisabled() return self.TextEntry:GetTabbingDisabled() end
function PANEL:SetTabbingDisabled(disabled) self.TextEntry:SetTabbingDisabled(disabled) end

function PANEL:GetPlaceholderText() return self.TextEntry:GetPlaceholderText() end
function PANEL:SetPlaceholderText(text) self.TextEntry:SetPlaceholderText(text) end

function PANEL:GetFont() return self.TextEntry:GetFont() end
function PANEL:SetFont(font) self.TextEntry:SetFontInternal(font) end

function PANEL:GetInt() return self.TextEntry:GetInt() end
function PANEL:GetFloat() return self.TextEntry:GetFloat() end

function PANEL:IsEditing() return self.TextEntry:IsEditing() end
function PANEL:SetEditable(enabled) self.TextEntry:SetEditable(enabled) end

function PANEL:AllowInput(value) end
function PANEL:GetAutoComplete(txt) end

function PANEL:OnKeyCode(code) end
function PANEL:OnEnter() end

function PANEL:OnGetFocus() end
function PANEL:OnLoseFocus() end

vgui.Register("PIXEL.TextEntry", PANEL, "Panel")