
--[[
PIXEL UI
Copyright (C) 2021 Tom O'Sullivan (Tom.bat)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "TextAlign", "TextAlign", FORCE_NUMBER)
AccessorFunc(PANEL, "TextColor", "TextColor")
AccessorFunc(PANEL, "Ellipses", "Ellipses", FORCE_BOOL)
AccessorFunc(PANEL, "AutoHeight", "AutoHeight", FORCE_BOOL)
AccessorFunc(PANEL, "AutoWidth", "AutoWidth", FORCE_BOOL)
AccessorFunc(PANEL, "AutoWrap", "AutoWrap", FORCE_BOOL)

PIXEL.RegisterFont("UI.Label", "Open Sans SemiBold", 14)

function PANEL:Init()
    self:SetText("Label")
    self:SetFont("UI.Label")
    self:SetTextAlign(TEXT_ALIGN_LEFT)
    self:SetTextColor(PIXEL.Colors.SecondaryText)
end

function PANEL:SetText(text)
    self.Text = text
    self.OriginalText = text
end

function PANEL:CalculateSize()
    PIXEL.SetFont(self:GetFont())
    return PIXEL.GetTextSize(self:GetText())
end

function PANEL:PerformLayout(w, h)
    local desiredW, desiredH = self:CalculateSize()

    if self:GetAutoWidth() then
        self:SetWide(desiredW)
    end

    if self:GetAutoHeight() then
        self:SetTall(desiredH)
    end

    if self:GetAutoWrap() then
        self.Text = PIXEL.WrapText(self.OriginalText, w, self:GetFont())
    end
end

function PANEL:Paint(w, h)
    local align = self:GetTextAlign()
    local text = self:GetEllipses() and PIXEL.EllipsesText(self:GetText(), w, self:GetFont()) or self:GetText()

    if align == TEXT_ALIGN_CENTER then
        PIXEL.DrawText(text, self:GetFont(), w / 2, 0, self:GetTextColor(), TEXT_ALIGN_CENTER)
        return
    elseif align == TEXT_ALIGN_RIGHT then
        PIXEL.DrawText(text, self:GetFont(), w, 0, self:GetTextColor(), TEXT_ALIGN_RIGHT)
        return
    end

    PIXEL.DrawText(text, self:GetFont(), 0, 0, self:GetTextColor())
end

vgui.Register("PIXEL.Label", PANEL, "Panel")