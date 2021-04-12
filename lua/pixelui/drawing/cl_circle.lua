
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

    function PIXEL.CreateCircle(x, y, ang, seg, pct, radius)
        local circle = {}

        insert(circle, {x = x, y = y})

        for i = 0, seg do
            local segAngle = rad(((i / seg) * -pct + ang))
            insert(circle, {x = x + sin(segAngle) * radius, y = y + cos(segAngle) * radius})
        end

        return circle
    end
end

local drawPoly = surface.DrawPoly
function PIXEL.DrawCircleUncached(x, y, ang, seg, pct, radius)
    drawPoly(PIXEL.CreateCircle(x, y, ang, seg, pct, radius))
end