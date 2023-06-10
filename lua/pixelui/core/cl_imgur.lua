
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

local materials = {}
local queue = {}

local useProxy = false

file.CreateDir("pixel")

local function processQueue()
    if queue[1] then
        local id, matSettings, callback = unpack(queue[1])

        http.Fetch((useProxy and "https://proxy.duckduckgo.com/iu/?u=https://i.imgur.com/" or "https://i.imgur.com/") .. id .. ".png",
            function(body, len, headers, code)
                if len > 2097152 then
                    materials[id] = Material("nil")
                else
                    file.Write("pixel/" .. id .. ".png", body)
                    materials[id] = Material("../data/pixel/" .. id .. ".png", matSettings or "noclamp smooth mips")
                end

                callback(materials[id])
            end,
            function(error)
                if useProxy then
                    materials[id] = Material("nil")
                    callback(materials[id])
                else
                    useProxy = true
                    processQueue()
                end
            end
        )
    end
end

function PIXEL.GetImgur(id, callback, _, matSettings)
    if materials[id] then
        callback(materials[id])
    elseif file.Exists("pixel/" .. id .. ".png", "DATA") then
        materials[id] = Material("../data/pixel/" .. id .. ".png", matSettings or "noclamp smooth mips")
        callback(materials[id])
    else
        table.insert(queue, {
            id,
            matSettings,
            function(mat)
                callback(mat)
                table.remove(queue, 1)
                processQueue()
            end
        })

        if #queue == 1 then
            processQueue()
        end
    end
end
