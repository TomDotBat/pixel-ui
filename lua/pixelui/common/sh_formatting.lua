
local round = math.Round
function PIXEL.FormatMoney(number)
    return DarkRP.formatMoney(round(number))
end

local floor, format = math.floor, string.format
function PIXEL.FormatTime(time)
    if not time then return end

    local s = time % 60
    time = floor(time / 60)

    local m = time % 60
    time = floor(time / 60)

    local h = time % 24
    time = floor(time / 24)

    local d = time % 7
    local w = floor(time / 7)

    if w ~= 0 then
        return format("%iw %id %ih %im %is", w, d, h, m, s)
    elseif d ~= 0 then
        return format("%id %ih %im %is", d, h, m, s)
    elseif h ~= 0 then
        return format("%ih %im %is", h, m, s)
    end

    return format("%im %is", m, s)
end