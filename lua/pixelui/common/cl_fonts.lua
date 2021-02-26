
PIXEL.UI.RegisteredFonts = PIXEL.UI.RegisteredFonts or {}
local registeredFonts = PIXEL.UI.RegisteredFonts

PIXEL.UI.SharedFonts = PIXEL.UI.SharedFonts or {}
local sharedFonts = PIXEL.UI.SharedFonts

function PIXEL.RegisterFontUnscaled(name, font, size, weight)
    weight = weight or 500

    local identifier = font .. size .. weight
    if sharedFonts[identifier] then return end

    local fontName = "PIXEL:" .. identifier
    registeredFonts[name] = fontName
    sharedFonts[identifier] = true

    surface.CreateFont(fontName, {
        font = font,
        size = size,
        weight = weight,
        antialias = true
    })
end

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