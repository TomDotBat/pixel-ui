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

--- PIXEL image button that loads Imgur assets.
---@class PIXEL.ImgurButton : PIXEL.ImageButton
local PANEL = {}

AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING)
AccessorFunc(PANEL, "ImgurSize", "ImgurSize", FORCE_NUMBER)

--- Sets the Imgur image identifier.
---@param id string Imgur image identifier.
function PANEL:SetImgurID(id)
    self.ImgurID = id
    self:SetImageURL("https://i.imgur.com/" .. id .. ".png")
end

--- Gets the Imgur image identifier parsed from the URL.
---@return string|nil id Parsed Imgur image identifier.
function PANEL:GetImgurID()
    return (self:GetImageURL() or ""):match("https://i.imgur.com/(.*).png")
end

--- Sets both image width and height using one size value.
---@param size number Image size in pixels.
function PANEL:SetImgurSize(size)
    self.ImgurSize = size
    self:SetImageSize(size, size)
end

--- Gets the configured image size.
---@return number width Image width.
---@return number height Image height.
function PANEL:GetImgurSize()
    return self:GetImageSize()
end

function PANEL:Init()
end

vgui.Register("PIXEL.ImgurButton", PANEL, "PIXEL.ImageButton")
