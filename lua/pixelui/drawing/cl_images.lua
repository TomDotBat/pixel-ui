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

local progressMat

local drawProgressWheel
local setMaterial = surface.SetMaterial
local setDrawColor = surface.SetDrawColor

do
    local min = math.min
    local curTime = CurTime
    local drawTexturedRectRotated = surface.DrawTexturedRectRotated

    --- Draws a spinning progress wheel.
    ---@param x number X position.
    ---@param y number Y position.
    ---@param w number Width.
    ---@param h number Height.
    ---@param col Color Tint color.
    function PIXEL.DrawProgressWheel(x, y, w, h, col)
        local progSize = min(w, h)
        setMaterial(progressMat)
        setDrawColor(col.r, col.g, col.b, col.a)
        drawTexturedRectRotated(x + w * .5, y + h * .5, progSize, progSize, -curTime() * 100)
    end
    drawProgressWheel = PIXEL.DrawProgressWheel
end

local materials = {}
local grabbingMaterials = {}

local getImage = PIXEL.GetImage
getImage(PIXEL.ProgressImageURL, function(mat)
    progressMat = mat
end)

local drawTexturedRect = surface.DrawTexturedRect
--- Draws a cached image or starts fetching it by URL.
---@param x number X position.
---@param y number Y position.
---@param w number Width.
---@param h number Height.
---@param url string Image URL to draw.
---@param col Color Tint color.
function PIXEL.DrawImage(x, y, w, h, url, col)
    if not materials[url] then
        drawProgressWheel(x, y, w, h, col)

        if grabbingMaterials[url] then return end
        grabbingMaterials[url] = true

        getImage(url, function(mat)
            materials[url] = mat
            grabbingMaterials[url] = nil
        end)

        return
    end

    setMaterial(materials[url])
    setDrawColor(col.r, col.g, col.b, col.a)
    drawTexturedRect(x, y, w, h)
end

local drawTexturedRectRotated = surface.DrawTexturedRectRotated
--- Draws a cached image rotated around its center.
---@param x number Center X position.
---@param y number Center Y position.
---@param w number Width.
---@param h number Height.
---@param rot number Rotation in degrees.
---@param url string Image URL to draw.
---@param col Color Tint color.
function PIXEL.DrawImageRotated(x, y, w, h, rot, url, col)
    if not materials[url] then
        drawProgressWheel(x - w * .5, y - h * .5, w, h, col)

        if grabbingMaterials[url] then return end
        grabbingMaterials[url] = true

        getImage(url, function(mat)
            materials[url] = mat
            grabbingMaterials[url] = nil
        end)

        return
    end

    setMaterial(materials[url])
    setDrawColor(col.r, col.g, col.b, col.a)
    drawTexturedRectRotated(x, y, w, h, rot)
end

--- Draws an Imgur image (PNG) by ID.
---@param x number X position.
---@param y number Y position.
---@param w number Width.
---@param h number Height.
---@param imgurId string Imgur image ID (without extension).
---@param col Color Tint color.
function PIXEL.DrawImgur(x, y, w, h, imgurId, col)
    local url = "https://i.imgur.com/" .. imgurId .. ".png"
    PIXEL.DrawImage(x, y, w, h, url, col)
end

--- Draws a rotated Imgur image (PNG) by ID.
---@param x number Center X position.
---@param y number Center Y position.
---@param w number Width.
---@param h number Height.
---@param rot number Rotation in degrees.
---@param imgurId string Imgur image ID (without extension).
---@param col Color Tint color.
function PIXEL.DrawImgurRotated(x, y, w, h, rot, imgurId, col)
    local url = "https://i.imgur.com/" .. imgurId .. ".png"
    PIXEL.DrawImageRotated(x, y, w, h, rot, url, col)
end
