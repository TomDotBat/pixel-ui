
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

local lerp = Lerp
function PIXEL.LerpColor(t, from, to)
    local newCol = Color(0, 0, 0)

    newCol.r = lerp(t, from.r, to.r)
    newCol.g = lerp(t, from.g, to.g)
    newCol.b = lerp(t, from.b, to.b)
    newCol.a = lerp(t, from.a, to.a)

    return newCol
end

function PIXEL.CopyColor(col)
    return Color(col.r, col.g, col.b, col.a)
end

function PIXEL.OffsetColor(col, offset)
    return Color(col.r + offset, col.g + offset, col.b + offset)
end

function PIXEL.Hue2RGB(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
    return p
end

function PIXEL.HSLToColor(h, s, l, a)
    local r, g, b
    local t = h / (2 * math.pi)

    if s == 0 then
        r, g, b = l, l, l
    else
        local q
        if l < 0.5 then
        q = l * (1 + s)
        else
        q = l + s - l * s
        end
        local p = 2 * l - q

        r = PIXEL.Hue2RGB(p, q, t + 1 / 3)
        g = PIXEL.Hue2RGB(p, q, t)
        b = PIXEL.Hue2RGB(p, q, t - 1 / 3)
    end

    return Color(r * 255, g * 255, b * 255, (a or 1) * 255)
end

function PIXEL.ColorToHSL(col)
    local r = col.r / 255
    local g = col.g / 255
    local b = col.b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    b = max + min
    local h = b / 2
    if max == min then return 0, 0, h end
    local s, l = h, h
    local d = max - min
    s = l > .5 and d / (2 - b) or d / b
    if max == r then h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    return h * .16667, s, l
end

function PIXEL.DecToHex(d, zeros)
    return string.format("%0" .. (zeros or 2) .. "x", d)
end

function PIXEL.RGBToHex(color)
    return "#" ..
        PIXEL.DecToHex(math.max(math.min(color.r, 255), 0)) ..
        PIXEL.DecToHex(math.max(math.min(color.g, 255), 0)) ..
        PIXEL.DecToHex(math.max(math.min(color.b, 255), 0))
end

function PIXEL.HexToRGB(hex)
    hex = hex:gsub("#", "")

    if (#hex == 3) then
        local r = hex:sub(1, 1)
        local g = hex:sub(2, 2)
        local b = hex:sub(3, 3)

        return Color(
        tonumber("0x" .. r .. r),
        tonumber("0x" .. g .. g),
        tonumber("0x" .. b .. b)
        )
    end

    return Color(
        tonumber("0x" .. hex:sub(1, 2)),
        tonumber("0x" .. hex:sub(3, 4)),
        tonumber("0x" .. hex:sub(5, 6))
    )
end

local lastUpdate = 0
local lastCol = Color(0, 0, 0)
local HSVToColor = HSVToColor
function PIXEL.GetRainbowColor()
    local time = CurTime()
    if lastUpdate == time then return lastCol end

    lastUpdate = time
    lastCol = HSVToColor((time * 50) % 360, 1, 1)

    return lastCol
end

local colorMeta = FindMetaTable("Color")

colorMeta.Copy = PIXEL.CopyColor
colorMeta.Offset = PIXEL.OffsetColor

function colorMeta:Lerp(amt, to)
    return PIXEL.LerpColor(amt, self, to)
end

function colorMeta:__eq(to)
    return self.r == to.r and self.g == to.g and self.b == to.b and self.a == to.a
end