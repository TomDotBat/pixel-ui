
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

AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING)
AccessorFunc(PANEL, "ImageSize", "ImageSize", FORCE_NUMBER)
AccessorFunc(PANEL, "NormalColor", "NormalColor")
AccessorFunc(PANEL, "HoverColor", "HoverColor")
AccessorFunc(PANEL, "ClickColor", "ClickColor")
AccessorFunc(PANEL, "DisabledColor", "DisabledColor")

function PANEL:Init()
    self.ImageCol = PIXEL.CopyColor(color_white)
    self:SetImgurID("635PPvg")

    self:SetNormalColor(color_white)
    self:SetHoverColor(color_white)
    self:SetClickColor(color_white)
    self:SetDisabledColor(color_white)

    self:SetImageSize(1)
end

function PANEL:PaintBackground(w, h) end

function PANEL:Paint(w, h)
    self:PaintBackground(w, h)

    local imageSize = h * self:GetImageSize()
    local imageOffset = (h - imageSize) / 2

    if not self:IsEnabled() then
        PIXEL.DrawImgur(imageOffset, imageOffset, imageSize, imageSize, self:GetImgurID(), self:GetDisabledColor())
        return
    end

    local col = self:GetNormalColor()

    if self:IsHovered() then
        col = self:GetHoverColor()
    end

    if self:IsDown() or self:GetToggle() then
        col = self:GetClickColor()
    end

    self.ImageCol = PIXEL.LerpColor(FrameTime() * 12, self.ImageCol, col)

    PIXEL.DrawImgur(imageOffset, imageOffset, imageSize, imageSize, self:GetImgurID(), self.ImageCol)
end

vgui.Register("PIXEL.ImgurButton", PANEL, "PIXEL.Button")