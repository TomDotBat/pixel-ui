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
]]

PIXEL.UI.RegisteredFonts = PIXEL.UI.RegisteredFonts or {}
local registeredFonts = PIXEL.UI.RegisteredFonts

do
    PIXEL.UI.SharedFonts = PIXEL.UI.SharedFonts or {}
    local sharedFonts = PIXEL.UI.SharedFonts

    function PIXEL.RegisterFontUnscaled(name, font, size, weight)
        weight = weight or 500

        local identifier = font .. size .. ":" .. weight

        local fontName = "PIXEL:" .. identifier
        registeredFonts[name] = fontName

        if sharedFonts[identifier] then return end
        sharedFonts[identifier] = true

        surface.CreateFont(fontName, {
            font = font,
            size = size,
            weight = weight,
            extended = true,
            antialias = true
        })
    end
end

do
    PIXEL.UI.ScaledFonts = PIXEL.UI.ScaledFonts or {}
    local scaledFonts = PIXEL.UI.ScaledFonts

    function PIXEL.RegisterFont(name, font, size, weight)
        scaledFonts[name] = {
            font = font,
            size = size,
            weight = weight
        }

        PIXEL.RegisterFontUnscaled(name, font, PIXEL.Scale(size), weight)
    end

    hook.Add("OnScreenSizeChanged", "PIXEL.UI.ReRegisterFonts", function()
        for k,v in pairs(scaledFonts) do
            PIXEL.RegisterFont(k, v.font, v.size, v.weight)
        end
    end)
end

do
    local setFont = surface.SetFont
    local function setPixelFont(font)
        local pixelFont = registeredFonts[font]
        if pixelFont then
            setFont(pixelFont)
            return
        end

        setFont(font)
    end

    PIXEL.SetFont = setPixelFont

    local getTextSize = surface.GetTextSize
    function PIXEL.GetTextSize(text, font)
        if font then setPixelFont(font) end
        return getTextSize(text)
    end

    function PIXEL.GetRealFont(font)
        return registeredFonts[font]
    end
end
