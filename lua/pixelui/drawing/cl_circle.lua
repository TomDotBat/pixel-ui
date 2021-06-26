
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

do
    local materials = {
        "4c5f5nk", --8
        "mONPuyy", --16
        "icx1Qbq", --32
        "TpwrpKe", --64
        "E8QbV5i", --128
        "wAr5H1x", --256
        "g52zxtK", --512
        "9tHAUp6", --1024
        "XAYX2uH" --2048
    }

    local max = math.max

    --Draws a circle at the specified coordinates with the given Color.
    --@tparam number the x position to start drawing at
    --@tparam number the y position to start drawing at
    --@tparam number the width of the circle
    --@tparam number the height of the circle
    --@tparam Color the Color of the circle
    function PIXEL.DrawCircle(x, y, w, h, col)
        local size = max(w, h)
        local id = materials[1]

        local curSize = 8
        for i = 1, #materials do
            if size <= curSize then break end
            id = materials[i + 1] or id
            curSize = curSize + curSize
        end

        PIXEL.DrawImgur(x, y, w, h, id, col)
    end
end

do
    local insert = table.insert
    local rad, sin, cos = math.rad, math.sin, math.cos

    --Creates a circle poly to be drawn with surface.DrawPoly.
    --@tparam number the x position of the center of the circle
    --@tparam number the y position of the center of the circle
    --@tparam number the angle to use (360 for full circle)
    --@tparam number the segment count, how many tris should make up this circle (higher values will be slower)
    --@tparam number the starting offset as an angle
    --@tparam number the radius of the circle in pixels
    --@treturn table a table of polygon points
    function PIXEL.CreateCircle(x, y, ang, seg, pct, radius)
        local circle = {}

        insert(circle, {x = x, y = y})

        for i = 0, seg do
            local segAngle = rad((i / seg) * -pct + ang)
            insert(circle, {x = x + sin(segAngle) * radius, y = y + cos(segAngle) * radius})
        end

        return circle
    end
end

local createCircle = PIXEL.CreateCircle
local drawPoly = surface.DrawPoly

--Draws a circle created using PIXEL.CreateCircle immediately when ran.
--@tparam number the x position of the center of the circle
--@tparam number the y position of the center of the circle
--@tparam number the angle to use (360 for full circle)
--@tparam number the segment count, how many tris should make up this circle (higher values will be slower)
--@tparam number the starting offset as an angle
--@tparam number the radius of the circle in pixels
--@see PIXEL.DrawCircle
function PIXEL.DrawCircleUncached(x, y, ang, seg, pct, radius)
    drawPoly(createCircle(x, y, ang, seg, pct, radius))
end