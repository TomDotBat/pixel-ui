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

PIXEL.DrawFullRoundedBoxEx = DrawFullRoundedBoxEx


function PIXEL.DrawRoundedBoxEx(borderSize, x, y, w, h, col, topLeft, topRight, bottomLeft, bottomRight)
    return DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, topLeft, topRight, bottomLeft, bottomRight)
end

function PIXEL.DrawRoundedBox(borderSize, x, y, w, h, col)
    return DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end

function PIXEL.DrawFullRoundedBox(borderSize, x, y, w, h, col)
    return DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end