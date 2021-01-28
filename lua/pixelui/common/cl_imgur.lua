
local materials = {}

file.CreateDir("pixel")

function PIXEL.GetImgur(id, callback, useproxy, matSettings)
    if materials[id] then return callback(materials[id]) end

    if file.Exists("pixel/" .. id .. ".png", "DATA") then
        materials[id] = Material("../data/pixel/" .. id .. ".png", matSettings or "noclamp smooth")
        return callback(materials[id])
    end

    http.Fetch(useproxy and "https://proxy.duckduckgo.com/iu/?u=https://i.imgur.com" or "https://i.imgur.com/" .. id .. ".png",
        function(body, len, headers, code)
            file.Write("pixel/" .. id .. ".png", body)
            materials[id] = Material("../data/pixel/" .. id .. ".png", matSettings or "noclamp smooth")
            return callback(materials[id])
        end,
        function(error)
            if useproxy then
                materials[id] = Material("nil")
                return callback(materials[id])
            end
            return PIXEL.GetImgur(id, callback, true)
        end
    )
end