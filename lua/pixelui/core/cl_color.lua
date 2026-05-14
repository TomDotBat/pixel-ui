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

do
    local format = string.format
    --- Converts a decimal value to a hex string.
    ---@param dec number Decimal value to convert.
    ---@param zeros number|nil Minimum digit count (defaults to 2).
    ---@return string hex Hex string representation.
    function PIXEL.DecToHex(dec, zeros)
        return format("%0" .. (zeros or 2) .. "x", dec)
    end

    local max = math.max
    local min = math.min
    --- Converts a Color to a "#RRGGBB" hex string.
    ---@param color Color Color to convert.
    ---@return string hex Hex string representation.
    function PIXEL.ColorToHex(color)
        return format("#%02X%02X%02X",
            max(min(color.r, 255), 0),
            max(min(color.g, 255), 0),
            max(min(color.b, 255), 0)
        )
    end
end

--- Converts a Color to HSL values.
---@param col Color Color to convert.
---@return number h Hue component (0-1).
---@return number s Saturation component (0-1).
---@return number l Lightness component (0-1).
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

    if max == r then
        h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
        h = (b - r) / d + 2
    elseif max == b then
        h = (r - g) / d + 4
    end

    return h * .16667, s, l
end

local createColor = Color
do
    local function hueToRgb(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1 / 6 then return p + (q - p) * 6 * t end
        if t < 1 / 2 then return q end
        if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
        return p
    end

    --- Converts HSL values to a Color (alpha defaults to 1).
    ---@param h number Hue component (0-1).
    ---@param s number Saturation component (0-1).
    ---@param l number Lightness component (0-1).
    ---@param a number|nil Alpha multiplier (0-1, defaults to 1).
    ---@return Color color Converted color.
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
            r = hueToRgb(p, q, t + 1 / 3)
            g = hueToRgb(p, q, t)
            b = hueToRgb(p, q, t - 1 / 3)
        end

        return createColor(r * 255, g * 255, b * 255, (a or 1) * 255)
    end
end

--- Returns a new instance of a Colour with the same values.
---@param col Color Color to copy.
---@return Color copy New color instance.
function PIXEL.CopyColor(col)
    return createColor(col.r, col.g, col.b, col.a)
end

--- Returns a Color with RGB channels offset by the given amount.
---@param col Color Base color to offset.
---@param offset number Amount to add to each RGB channel.
---@return Color offsetColor Offset color copy.
function PIXEL.OffsetColor(col, offset)
    return createColor(col.r + offset, col.g + offset, col.b + offset)
end

do
    local match = string.match
    local tonumber = tonumber

    --- Converts a "#RRGGBB" hex string to a Color.
    ---@param hex string Hex string to convert.
    ---@return Color color Converted color.
    function PIXEL.HexToColor(hex)
        local r, g, b = match(hex, "#(..)(..)(..)")
        return createColor(
            tonumber(r, 16),
            tonumber(g, 16),
            tonumber(b, 16)
        )
    end
end

do
    local curTime = CurTime
    local hsvToColor = HSVToColor

    local lastUpdate = 0
    local lastCol = createColor(0, 0, 0)

    --- Returns a cached rainbow Color based on CurTime.
    ---@return Color color Cached rainbow color.
    function PIXEL.GetRainbowColor()
        local time = curTime()
        if lastUpdate == time then return lastCol end

        lastUpdate = time
        lastCol = hsvToColor((time * 50) % 360, 1, 1)

        return lastCol
    end
end

do
    local colorToHSL = ColorToHSL

    --- Returns true if the color is considered light.
    ---@param col Color Color to evaluate.
    ---@return boolean isLight True when lightness is >= 0.5.
    function PIXEL.IsColorLight(col)
        local _, _, lightness = colorToHSL(col)
        return lightness >= .5
    end
end

--- Linearly interpolates between two colors.
---@param t number Lerp fraction between 0 and 1.
---@param from Color Starting color.
---@param to Color Target color.
---@return Color color Interpolated color.
function PIXEL.LerpColor(t, from, to)
    return createColor(from.r, from.g, from.b, from.a):Lerp(to, t)
end

--- Returns true if two Colors are equal.
---@param from Color First color to compare.
---@param to Color Second color to compare.
---@return boolean isEqual True when all RGBA channels match.
function PIXEL.IsColorEqualTo(from, to)
    return from.r == to.r and from.g == to.g and from.b == to.b and from.a == to.a
end

local colorMeta = FindMetaTable("Color")
--- Returns a copy of this color.
---@param self Color Color instance to copy.
---@return Color copy New color instance.
colorMeta.Copy = PIXEL.CopyColor
--- Returns true if this color is considered light.
---@param self Color Color instance to evaluate.
---@return boolean isLight True when lightness is >= 0.5.
colorMeta.IsLight = PIXEL.IsColorLight
--- Returns true if this color equals another color.
---@param self Color Color instance to compare.
---@param to Color Color to compare against.
---@return boolean isEqual True when all RGBA channels match.
colorMeta.EqualTo = PIXEL.IsColorEqualTo

--- Offsets this color's RGB channels in place.
---@param offset number Amount to add to each RGB channel.
---@return Color self Updated color.
function colorMeta:Offset(offset)
    self.r = self.r + offset
    self.g = self.g + offset
    self.b = self.b + offset
    return self
end

-- Combatibility for versions before 2024.06.28
if not colorMeta.Lerp then
    local lerp = Lerp
    local isColor = IsColor
    local deprecation_warning_shown = false
    --- Interpolates this color towards a target color.
    ---@param target Color Target color to interpolate towards.
    ---@param fraction number Lerp fraction between 0 and 1.
    ---@return Color self Updated color.
    function colorMeta:Lerp(target, fraction)
        if isColor(fraction) then
            -- Don't break addons using this based on Pixel UI for now.
            local rememberFraction = fraction
            fraction = target
            target = rememberFraction

            if not deprecation_warning_shown then
                deprecation_warning_shown = true
                -- Scream at them at least once though, should be fine to keep this backwards compatibility until the update. 
                ErrorNoHaltWithStack("Deprecated PIXEL-UI Color:Lerp(fraction, target) is used.")
            end
        end

        self.r = lerp(fraction, self.r, target.r)
        self.g = lerp(fraction, self.g, target.g)
        self.b = lerp(fraction, self.b, target.b)
        self.a = lerp(fraction, self.a, target.a)
        return self
    end
end
