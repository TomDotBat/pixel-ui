
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

local tableInsert = table.insert
local mathRad, mathSin, mathCos = math.rad, math.sin, math.cos
local surfaceSetDrawColor, surfaceDrawPoly = surface.SetDrawColor, surface.DrawPoly
local drawNoTexture = draw.NoTexture

function PIXEL.CreateCircle(x, y, ang, seg, p, rad, color)
    local circle = {}
    circle.poly = {}
    circle.color = color

    tableInsert(circle.poly, {x = x, y = y})

    for i = 0, seg do
        local segdata = mathRad(((i / seg ) * -p + ang))
        tableInsert(circle.poly, {x = x + mathSin(segdata) * rad, y = y + mathCos(segdata) * rad})
    end

    return circle
end

function PIXEL.DrawCircleUncached(x, y, ang, seg, p, rad, color)
    PIXEL.DrawCachedCircle(PIXEL.CreateCircle(x, y, ang, seg, p, rad, color))
end

function PIXEL.DrawCachedCircle(circle)
    surfaceSetDrawColor(circle.color)
    drawNoTexture()
    surfaceDrawPoly(circle.poly)
end