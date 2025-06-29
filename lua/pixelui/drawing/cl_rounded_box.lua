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

function PIXEL.DrawRoundedBoxEx(borderSize, x, y, w, h, col, topLeft, topRight, bottomLeft, bottomRight)
	return PIXEL.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, topLeft, topRight, bottomLeft, bottomRight)

end

function PIXEL.DrawRoundedBox(borderSize, x, y, w, h, col)
	return PIXEL.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end

function PIXEL.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, tl, tr, bl, br)
	local flags = PIXEL.RNDX.SHAPE_CIRCLE

	if tl == false then flags = flags + PIXEL.RNDX.NO_TL end
	if tr == false then flags = flags + PIXEL.RNDX.NO_TR end
	if bl == false then flags = flags + PIXEL.RNDX.NO_BL end
	if br == false then flags = flags + PIXEL.RNDX.NO_BR end

	PIXEL.RNDX.Draw(borderSize, x, y, w, h, col, flags)
end

function PIXEL.DrawFullRoundedBox(borderSize, x, y, w, h, col)
	return PIXEL.DrawFullRoundedBoxEx(borderSize, x, y, w, h, col, true, true, true, true)
end