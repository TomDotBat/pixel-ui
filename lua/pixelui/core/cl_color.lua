
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

--Converts 3 number values that represent HSL into a Color object.
--@tparam number hue
--@tparam number saturation
--@tparam number lightness
--@treturn Color color
PIXEL.HSLToColor = HSLToColor

--Converts a Color object into 3 number values that represent HSL.
--@tparam Color color
--@treturn number hue
--@treturn number saturation
--@treturn number lightness
PIXEL.ColorToHSL = ColorToHSL

do
    local format = string.format
    
    --Converts a base 10 number to hexadecimal.
    --@tparam number the base 10 number
    --@tparam number[opt=2] the amount of zeros to add
    --@treturn string the number given in a hexadecimal string
    function PIXEL.DecToHex(dec, zeros)
        return format("%0" .. (zeros or 2) .. "x", dec)
    end

    local max = math.max
    local min = math.min
    
    --Converts a Color object to a hexadecimal string.
    --@tparam Color the color to convert
    --@treturn string the Color given in a hexadecimal string
    function PIXEL.ColorToHex(color)
        return format("#%02X%02X%02X",
            max(min(color.r, 255), 0),
            max(min(color.g, 255), 0),
            max(min(color.b, 255), 0)
        )
    end
end

local createColor = Color

--Instantiates a new Color object with the same values as the one given.
--@tparam Color the Color object to make a copy of
--@treturn Color a copy of the Color object given
function PIXEL.CopyColor(col)
    return createColor(col.r, col.g, col.b, col.a)
end

--Offsets all the values in a Color object by the number given.
--@tparam Color the Color to offset the values of
--@tparam number the amount the Color values should be adjusted by
--@treturn Color a new Color object with the values offset accordingly
function PIXEL.OffsetColor(col, offset)
    return createColor(col.r + offset, col.g + offset, col.b + offset)
end

do
    local match = string.match
    local tonumber = tonumber

    --Converts a hexadecimal string to a Color object.
    --@tparam string a hexadecimal string
    --@treturn Color the hexadecimal string given as a Color
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

    --Gets a Color that cycles through the colours of a rainbow.
    --@treturn Color the rainbow color
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

    --Checks if a Color's lightness is more than 50%.
    --@tparam Color the colour to check the lightness of
    --@treturn bool whether the Color is light or not
    function PIXEL.IsColorLight(col)
        local _, _, lightness = colorToHSL(col)
        return lightness >= .5
    end
end

--Linearly interpolates the values between two Color objects by a defined amount.
--@tparam number a decimal percentage representing the progress between the two given Color objects
--@tparam Color the Color to lerp from
--@tparam Color the Color to lerp towards
--@treturn Color a new Color with values that have been lerped accordingly
function PIXEL.LerpColor(t, from, to)
    return createColor(from.r, from.g, from.b, from.a):Lerp(t, to)
end

--Checks whether a Color is equal to another by comparing their values.
--@tparam Color color 1
--@tparam Color color 2
--@return bool whether the Color objects have the same values or not
function PIXEL.IsColorEqualTo(from, to)
    return from.r == to.r and from.g == to.g and from.b == to.b and from.a == to.a
end

local colorMeta = FindMetaTable("Color")

--Instantiates a new Color object with the same values as the one the function was referenced through.
--@treturn Color a copy of the Color referenced
colorMeta.Copy = PIXEL.CopyColor

--Checks if the lightness of the Color the function was referenced through is more than 50%.
--@treturn bool whether the Color is light or not
colorMeta.IsLight = PIXEL.IsColorLight

--Checks whether a Color is equal to another by comparing their values.
--@tparam Color color to compare against
--@return bool whether the Color given has the same values as the color the function was referenced from
colorMeta.EqualTo = PIXEL.IsColorEqualTo

--Offsets all the values in a Color object by the number given and modifies them 
--@tparam number the amount the Color values should be adjusted by
--@treturn Color the Color object the method was called on
function colorMeta:Offset(offset)
    self.r = self.r + offset
    self.g = self.g + offset
    self.b = self.b + offset
    return self
end

local lerp = Lerp

--Linearly interpolates the values between two Color objects by a defined amount.
--@tparam number a decimal percentage representing the progress between the two given Color objects
--@tparam Color the Color to lerp towards
--@treturn Color the Color object the method was called on
function colorMeta:Lerp(t, to)
    self.r = lerp(t, self.r, to.r)
    self.g = lerp(t, self.g, to.g)
    self.b = lerp(t, self.b, to.b)
    self.a = lerp(t, self.a, to.a)
    return self
end
