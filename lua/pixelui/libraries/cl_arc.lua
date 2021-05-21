
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

--https://gist.github.com/theawesomecoder61/d2c3a3d42bbce809ca446a85b4dda754

-- Draws an arc on your screen.
-- startang and endang are in degrees, 
-- radius is the total radius of the outside edge to the center.
-- cx, cy are the x,y coordinates of the center of the arc.
-- roughness determines how many triangles are drawn. Number between 1-360; 2 or 3 is a good number.
function PIXEL.DrawUncachedArc(cx, cy, radius, thickness, startang, endang, roughness, color)
    surface.SetDrawColor(color)
    PIXEL.DrawArc(PIXEL.PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness))
end

function PIXEL.PrecacheArc(cx, cy, radius, thickness, startang, endang, roughness)
    local triarc = {}
    -- local deg2rad = math.pi / 180
    -- Define step
    roughness = math.max(roughness or 1, 1)
    local step = roughness
    -- Correct start/end ang
    startang, endang = startang or 0, endang or 0

    if startang > endang then
        step = math.abs(step) * -1
    end

    -- Create the inner circle's points.
    local inner = {}
    local r = radius - thickness

    for deg = startang, endang, step do
        local rad = math.rad(deg)
        -- local rad = deg2rad * deg
        local ox, oy = cx + (math.cos(rad) * r), cy + (-math.sin(rad) * r)

        table.insert(inner, {
            x = ox,
            y = oy,
            u = (ox - cx) / radius + .5,
            v = (oy - cy) / radius + .5
        })
    end

    -- Create the outer circle's points.
    local outer = {}

    for deg = startang, endang, step do
        local rad = math.rad(deg)
        -- local rad = deg2rad * deg
        local ox, oy = cx + (math.cos(rad) * radius), cy + (-math.sin(rad) * radius)

        table.insert(outer, {
            x = ox,
            y = oy,
            u = (ox - cx) / radius + .5,
            v = (oy - cy) / radius + .5
        })
    end

    -- Triangulize the points.
    -- twice as many triangles as there are degrees.
    for tri = 1, #inner * 2 do
        local p1, p2, p3
        p1 = outer[math.floor(tri / 2) + 1]
        p3 = inner[math.floor((tri + 1) / 2) + 1]

        --if the number is even use outer.
        if tri % 2 == 0 then
            p2 = outer[math.floor((tri + 1) / 2)]
        else
            p2 = inner[math.floor((tri + 1) / 2)]
        end

        table.insert(triarc, {p1, p2, p3})
    end
    -- Return a table of triangles to draw.

    return triarc
end

--Draw a premade arc.
function PIXEL.DrawArc(arc)
    for k, v in ipairs(arc) do
        surface.DrawPoly(v)
    end
end