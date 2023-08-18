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

AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING)
AccessorFunc(PANEL, "ImgurSize", "ImgurSize", FORCE_NUMBER)

function PANEL:SetImgurID(id)
    assert(type(id) == "string", "bad argument #1 to 'SetImgurID' (string expected, got " .. type(id))
    print("[PIXEL UI] PIXEL.ImgurButton:SetImgurID is deprecated, use PIXEL.ImageButton:SetImageURL instead.")
    self.ImgurID = id
    self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
end

function PANEL:GetImgurID()
    print("[PIXEL UI] PIXEL.ImgurButton:GetImgurID is deprecated, use PIXEL.ImageButton:GetImgurID instead.")
    return self:GetImageURL():match("https://i.imgur.com/(.*).png")
end

function PANEL:SetImgurSize(size)
    assert(type(size) == "number", "bad argument #1 to 'SetImgurSize' (number expected, got " .. type(size))
    print("[PIXEL UI] PIXEL.ImgurButton:SetImgurSize is deprecated, use PIXEL.ImageButton:SetImageSize instead.")
    self.ImgurSize = size
    self:SetImageSize(size, size)
end

function PANEL:GetImgurSize()
    print("[PIXEL UI] PIXEL.ImgurButton:GetImgurSize is deprecated, use PIXEL.ImageButton:GetImageSize instead.")
    return self:GetImageSize()
end

function PANEL:Init()
    print("[PIXEL UI] PIXEL.ImgurButton is deprecated, use PIXEL.ImageButton instead.")
end

vgui.Register("PIXEL.ImgurButton", PANEL, "PIXEL.Imagebutton")