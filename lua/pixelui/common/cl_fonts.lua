
function PIXEL.RegisterFontUnscaled(name, font, size, weight)
    surface.CreateFont("PIXEL." .. name, {
        font = font,
        size = size,
        weight = weight or 500,
        antialias = true
    })
end

local scaledFonts = {}

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