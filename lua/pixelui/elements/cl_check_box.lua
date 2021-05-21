
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

function PANEL:Init()
    self:SetIsToggle(true)

    local boxSize = PIXEL.Scale(20)
    self:SetSize(boxSize, boxSize)

    self:SetImgurID("YvG7VI6")

    self:SetNormalColor(PIXEL.Colors.Transparent)
    self:SetHoverColor(PIXEL.Colors.PrimaryText)
    self:SetClickColor(PIXEL.Colors.PrimaryText)
    self:SetDisabledColor(PIXEL.Colors.Transparent)

    self:SetImageSize(.8)

    self.BackgroundCol = PIXEL.CopyColor(PIXEL.Colors.Primary)
end

function PANEL:PaintBackground(w, h)
    if not self:IsEnabled() then
        PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, PIXEL.Colors.Disabled)
        self:PaintExtra(w, h)
        return
    end

    local bgCol = PIXEL.Colors.Primary

    if self:IsDown() or self:GetToggle() then
        bgCol = PIXEL.Colors.Positive
    end

    local animTime = FrameTime() * 12
    self.BackgroundCol = PIXEL.LerpColor(animTime, self.BackgroundCol, bgCol)

    PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, self.BackgroundCol)
end

vgui.Register("PIXEL.Checkbox", PANEL, "PIXEL.ImgurButton")