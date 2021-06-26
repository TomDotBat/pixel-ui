
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

local cornerTex8 = surface.GetTextureID("gui/corner8")
local cornerTex16 = surface.GetTextureID("gui/corner16")
local cornerTex32 = surface.GetTextureID("gui/corner32")
local cornerTex64 = surface.GetTextureID("gui/corner64")
local cornerTex512 = surface.GetTextureID("gui/corner512")

local round = math.Round
local min = math.min
local floor = math.floor

local setDrawColor = surface.SetDrawColor
local drawRect = surface.DrawRect
local drawTexturedRectUV = surface.DrawTexturedRectUV
local setTexture = surface.SetTexture

--Draws a rounded box with the ability to round individual corners.
--@tparam number the border radius of the rounded box
--@tparam number the x position to begin drawing from
--@tparam number the y position to begin drawing from
--@tparam number the width of the box
--@tparam number the height of the box
--@tparam Color the Color of the box
--@tparam bool whether the top left corner should be rounded
--@tparam bool whether the top right corner should be rounded
--@tparam bool whether the bottom left corner should be rounded
--@tparam bool whether the bottom right corner should be rounded
function PIXEL.DrawRoundedBoxEx(borderSize, x, y, w, h, col, topLeft, topRight, bottomLeft, bottomRight)
	setDrawColor(col.r, col.g, col.b, col.a)

	if borderSize <= 0 then
		drawRect(x, y, w, h)
		return
	end

	x = round(x)
	y = round(y)
	w = round(w)
	h = round(h)
	borderSize = min(round(borderSize), floor(w / 2))

	drawRect(x + borderSize, y, w - borderSize * 2, h)
	drawRect(x, y + borderSize, borderSize, h - borderSize * 2)
	drawRect(x + w - borderSize, y + borderSize, borderSize, h - borderSize * 2)

	local tex = cornerTex8
	if borderSize > 8 then tex = cornerTex16 end
	if borderSize > 16 then tex = cornerTex32 end
	if borderSize > 32 then tex = cornerTex64 end
	if borderSize > 64 then tex = cornerTex512 end

	setTexture(tex)

	if topLeft then
		drawTexturedRectUV(x, y, borderSize, borderSize, 0, 0, 1, 1)
	else
		drawRect(x, y, borderSize, borderSize)
	end

	if topRight then
		drawTexturedRectUV(x + w - borderSize, y, borderSize, borderSize, 1, 0, 0, 1)
	else
		drawRect(x + w - borderSize, y, borderSize, borderSize)
	end

	if bottomLeft then
		drawTexturedRectUV(x, y + h -borderSize, borderSize, borderSize, 0, 1, 1, 0)
	else
		drawRect(x, y + h - borderSize, borderSize, borderSize)
	end

	if bottomRight then
		drawTexturedRectUV(x + w - borderSize, y + h - borderSize, borderSize, borderSize, 1, 1, 0, 0)
	else
		drawRect(x + w - borderSize, y + h - borderSize, borderSize, borderSize)
	end
end

local drawRoundedBoxEx = PIXEL.DrawRoundedBoxEx

--Draws a rounded box.
--@tparam number the border radius of the rounded box
--@tparam number the x position to begin drawing from
--@tparam number the y position to begin drawing from
--@tparam number the width of the box
--@tparam number the height of the box
--@tparam Color the Color of the box
function PIXEL.DrawRoundedBox(borderSize, x, y, w, h, col)
	return drawRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end

local roundedBoxCache = {}
local whiteTexture = surface.GetTextureID("vgui/white")

local drawPoly = surface.DrawPoly

--Draws a rounded box as a polygon, and with the ability to round individual corners.
--@tparam number the border radius of the rounded box
--@tparam number the x position to begin drawing from
--@tparam number the y position to begin drawing from
--@tparam number the width of the box
--@tparam number the height of the box
--@tparam Color the Color of the box
--@tparam bool whether the top left corner should be rounded
--@tparam bool whether the top right corner should be rounded
--@tparam bool whether the bottom left corner should be rounded
--@tparam bool whether the bottom right corner should be rounded
function PIXEL.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, tl, tr, bl, br)
	setDrawColor(col.r, col.g, col.b, col.a)

	if borderSize <= 0 then
		drawRect(x, y, w, h)
		return
	end

	local fullRight = x + w
	local fullBottom = y + h

	local left, right = x + borderSize, fullRight - borderSize
	local top, bottom = y + borderSize, fullBottom - borderSize

	local halfBorder = borderSize * .7

	local cacheName = borderSize .. x .. y .. w .. h
	local cache = roundedBoxCache[cacheName]
	if not cache then
		cache = {
			{x = right, y = y}, --Top Right
			{x = right + halfBorder, y = top - halfBorder},
			{x = fullRight, y = top},

			{x = fullRight, y = bottom}, --Bottom Right
			{x = right + halfBorder, y = bottom + halfBorder},
			{x = right, y = fullBottom},

			{x = left, y = fullBottom}, --Bottom Left
			{x = left - halfBorder, y = bottom + halfBorder},
			{x = x, y = bottom},

			{x = x, y = top}, --Top Left
			{x = left - halfBorder, y = top - halfBorder},
			{x = left, y = y}
		}

		roundedBoxCache[cacheName] = cache
	end

	setTexture(whiteTexture)
	drawPoly(cache)

	if not tl then drawRect(x, y, borderSize, borderSize) end
	if not tr then drawRect(x + w - borderSize, y, borderSize, borderSize) end
	if not bl then drawRect(x, y + h - borderSize, borderSize, borderSize) end
	if not br then drawRect(x + w - borderSize, y + h - borderSize, borderSize, borderSize) end
end


--Draws a rounded box as a polygon.
--@tparam number the border radius of the rounded box
--@tparam number the x position to begin drawing from
--@tparam number the y position to begin drawing from
--@tparam number the width of the box
--@tparam number the height of the box
--@tparam Color the Color of the box
function PIXEL.DrawFullRoundedBox(borderSize, x, y, w, h, col)
	return PIXEL.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end