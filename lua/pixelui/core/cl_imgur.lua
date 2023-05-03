
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

local downloadQueue = {}
local queueRunning = false

local materials = {}

file.CreateDir("pixel")

function PIXEL.RunImgurQueue()
    if queueRunning then return end
    queueRunning = true

    for k, v in ipairs(downloadQueue) do
        local id, callback, useproxy, matSettings = v.id, v.callback, v.useproxy, v.matSettings

        http.Fetch(useproxy and "https://proxy.duckduckgo.com/iu/?u=https://i.imgur.com" or "https://i.imgur.com/" .. id .. ".png",
            function(body, len, headers, code)
                if len > 2097152 then
                    materials[id] = Material("nil")
                    return callback(materials[id])
                end

                file.Write("pixel/" .. id .. ".png", body)
                materials[id] = Material("../data/pixel/" .. id .. ".png", matSettings or "noclamp smooth mips")
                downloadQueue[k] = nil

                return callback(materials[id])
            end,
            function(error)
                if useproxy then
                    materials[id] = Material("nil")
                    downloadQueue[k] = nil
                    return callback(materials[id])
                end
                return PIXEL.GetImgur(id, callback, true)
            end
        )
    end

    queueRunning = false
end

function PIXEL.GetImgur(id, callback, useproxy, matSettings)
    if materials[id] then return callback(materials[id]) end

    if file.Exists("pixel/" .. id .. ".png", "DATA") then
        materials[id] = Material("../data/pixel/" .. id .. ".png", matSettings or "noclamp smooth mips")
        return callback(materials[id])
    end

    table.insert(downloadQueue, {
        id = id,
        callback = callback,
        useproxy = useproxy,
        matSettings = matSettings
    })
end
