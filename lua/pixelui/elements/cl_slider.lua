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
    self.Fraction = 0

    self.Grip = vgui.Create("PIXEL.ImageButton", self)
    self.Grip:NoClipping(true)

    self.Grip:SetImageURL("https://cdn.lythium.dev/u/1obHSC.png")
    self.Grip:SetNormalColor(PIXEL.CopyColor(PIXEL.Colors.Primary))
    self.Grip:SetHoverColor(PIXEL.OffsetColor(PIXEL.Colors.Primary, -15))
    self.Grip:SetClickColor(PIXEL.OffsetColor(PIXEL.Colors.Primary, 15))

    self.Grip.OnCursorMoved = function(pnl, x, y)
        if not pnl.Depressed then return end

        x, y = pnl:LocalToScreen(x, y)
        x = self:ScreenToLocal(x, y)

        self.Fraction = math.Clamp(x / self:GetWide(), 0, 1)

        self:OnValueChanged(self.Fraction)
        self:InvalidateLayout()
    end

    self.BackgroundCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 20)
    self.FillCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 10)
end

function PANEL:OnMousePressed()
    local w = self:GetWide()

    self.Fraction = math.Clamp(self:CursorPos() / w, 0, 1)
    self:OnValueChanged(self.Fraction)
    self:InvalidateLayout()
end

function PANEL:OnValueChanged(fraction) end

function PANEL:Paint(w, h)
    local rounding = h * .5
    PIXEL.DrawRoundedBox(rounding, 0, 0, w, h, self.BackgroundCol)
    PIXEL.DrawRoundedBox(rounding, 0, 0, self.Fraction * w, h, self.FillCol)
end

function PANEL:PerformLayout(w, h)
    local gripSize = h + PIXEL.Scale(6)
    local offset = PIXEL.Scale(3)
    self.Grip:SetSize(gripSize, gripSize)
    self.Grip:SetPos((self.Fraction * w) - (gripSize * .5), -offset)
end

vgui.Register("PIXEL.Slider", PANEL, "PIXEL.Button")