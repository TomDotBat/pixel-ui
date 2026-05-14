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

local RNDX_DRAW, RNDX_FLAG_TL, RNDX_FLAG_TR, RNDX_FLAG_BL, RNDX_FLAG_BR, RNDX_SHAPE_CIRCLE

--- Draws a rounded box using PIXEL.RNDX with per-corner toggles.
---@param borderSize number
---@param x number
---@param y number
---@param w number
---@param h number
---@param col Color
---@param tl boolean|nil
---@param tr boolean|nil
---@param bl boolean|nil
---@param br boolean|nil
local function DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, tl, tr, bl, br)
    if not RNDX_DRAW then
        -- just in case this frame we still dont have it
        if not PIXEL.RNDX then return end

        RNDX_DRAW = PIXEL.RNDX.Draw
        RNDX_FLAG_TL = PIXEL.RNDX.NO_TL
        RNDX_FLAG_TR = PIXEL.RNDX.NO_TR
        RNDX_FLAG_BL = PIXEL.RNDX.NO_BL
        RNDX_FLAG_BR = PIXEL.RNDX.NO_BR
        RNDX_SHAPE_CIRCLE = PIXEL.RNDX.SHAPE_CIRCLE
    end

    local flags = RNDX_SHAPE_CIRCLE

    if tl == false then flags = flags + RNDX_FLAG_TL end
    if tr == false then flags = flags + RNDX_FLAG_TR end
    if bl == false then flags = flags + RNDX_FLAG_BL end
    if br == false then flags = flags + RNDX_FLAG_BR end

    RNDX_DRAW(borderSize, x, y, w, h, col, flags)
end

---@type fun(borderSize: number, x: number, y: number, w: number, h: number, col: Color, tl: boolean|nil, tr: boolean|nil, bl: boolean|nil, br: boolean|nil)
PIXEL.DrawFullRoundedBoxEx = DrawFullRoundedBoxEx


--- Alias for DrawFullRoundedBoxEx.
---@param borderSize number
---@param x number
---@param y number
---@param w number
---@param h number
---@param col Color
---@param topLeft boolean|nil
---@param topRight boolean|nil
---@param bottomLeft boolean|nil
---@param bottomRight boolean|nil
function PIXEL.DrawRoundedBoxEx(borderSize, x, y, w, h, col, topLeft, topRight, bottomLeft, bottomRight)
    return DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, topLeft, topRight, bottomLeft, bottomRight)
end

--- Draws a rounded box with all corners enabled.
---@param borderSize number
---@param x number
---@param y number
---@param w number
---@param h number
---@param col Color
function PIXEL.DrawRoundedBox(borderSize, x, y, w, h, col)
    return DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end

--- Draws a full rounded box (alias of DrawRoundedBox).
---@param borderSize number
---@param x number
---@param y number
---@param w number
---@param h number
---@param col Color
function PIXEL.DrawFullRoundedBox(borderSize, x, y, w, h, col)
    return DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end
