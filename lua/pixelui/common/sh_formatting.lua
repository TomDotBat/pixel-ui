
do
    local currencySymbol = "$"
    local currencyLeft = true

    hook.Add("PostGamemodeLoaded", "PIXEL.UI.GetMoneyFormatSettings", function()
        local config = (GM or GAMEMODE).Config
        if not config then return end

        if config.currency then currencySymbol = config.currency end
        if config.currencyLeft then currencyLeft = config.currencyLeft end
    end)

    local function addCurrency(str)
        return currencyLeft and (currencySymbol .. str) or (str .. currencySymbol)
    end

    do
        local tostring = tostring
        local find = string.find
        local abs = math.abs
        local round = math.Round

        function PIXEL.FormatMoney(val)
            if not val then return addCurrency("0") end

            val = round(val)

            if val >= 1e14 then return addCurrency(tostring(val)) end
            if val <= -1e14 then return "-" .. addCurrency(tostring(abs(val))) end

            local negative = val < 0

            val = tostring(abs(val))
            local dp = find(val, "%.") or #val + 1

            for i = dp - 4, 1, -3 do
                val = val:sub(1, i) .. "," .. val:sub(i + 1)
            end

            if val[#val - 1] == "." then
                val = val .. "0"
            end

            return (negative and "-" or "") .. addCurrency(val)
        end
    end
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