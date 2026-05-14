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

local RNDX_SHAPE_CIRCLE, RNDX_NO_TL, RNDX_NO_TR, RNDX_NO_BL, RNDX_NO_BR, RNDX_DRAW_OUTLINED

--- Draws a simple outlined box using PIXEL.RNDX.
---@param x number X position.
---@param y number Y position.
---@param w number Width.
---@param h number Height.
---@param thickness number Outline thickness.
---@param col Color Outline color.
function PIXEL.DrawOutlinedBox(x, y, w, h, thickness, col)
	PIXEL.RNDX.DrawOutlined(0, x, y, w, h, col, thickness)
end

--- Draws an outlined rounded box with per-corner toggles.
---@param borderSize number Corner radius.
---@param x number X position.
---@param y number Y position.
---@param w number Width.
---@param h number Height.
---@param col Color Outline color.
---@param thickness number Outline thickness.
---@param tl boolean|nil Whether top-left corner is rounded.
---@param tr boolean|nil Whether top-right corner is rounded.
---@param bl boolean|nil Whether bottom-left corner is rounded.
---@param br boolean|nil Whether bottom-right corner is rounded.
local function DrawOutlinedRoundedBoxEx(borderSize, x, y, w, h, col, thickness, tl, tr, bl, br)
	if not RDNX_DRAW_OUTLINED then
		if not PIXEL.RNDX then return end

		RNDX_SHAPE_CIRCLE = PIXEL.RNDX.SHAPE_CIRCLE
		RNDX_NO_TL = PIXEL.RNDX.NO_TL
		RNDX_NO_TR = PIXEL.RNDX.NO_TR
		RNDX_NO_BL = PIXEL.RNDX.NO_BL
		RNDX_NO_BR = PIXEL.RNDX.NO_BR
		RNDX_DRAW_OUTLINED = PIXEL.RNDX.DrawOutlined
	end

	local flags = RNDX_SHAPE_CIRCLE

	if tl == false then flags = flags + RNDX_NO_TL end
	if tr == false then flags = flags + RNDX_NO_TR end
	if bl == false then flags = flags + RNDX_NO_BL end
	if br == false then flags = flags + RNDX_NO_BR end

	RNDX_DRAW_OUTLINED(borderSize, x, y, w, h, col, thickness, flags)
end

--- Draws an outlined rounded box with per-corner toggles.
---@param borderSize number Corner radius.
---@param x number X position.
---@param y number Y position.
---@param w number Width.
---@param h number Height.
---@param col Color Outline color.
---@param thickness number Outline thickness.
---@param tl boolean|nil Whether top-left corner is rounded.
---@param tr boolean|nil Whether top-right corner is rounded.
---@param bl boolean|nil Whether bottom-left corner is rounded.
---@param br boolean|nil Whether bottom-right corner is rounded.
PIXEL.DrawOutlinedRoundedBoxEx = DrawOutlinedRoundedBoxEx

--- Draws an outlined rounded box with all corners enabled.
---@param borderSize number Corner radius.
---@param x number X position.
---@param y number Y position.
---@param w number Width.
---@param h number Height.
---@param col Color Outline color.
---@param thickness number Outline thickness.
function PIXEL.DrawOutlinedRoundedBox(borderSize, x, y, w, h, col, thickness)
	return DrawOutlinedRoundedBoxEx(borderSize, x, y, w, h, col, thickness, true, true, true, true)
end
