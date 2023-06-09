
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

local imgurQueue = {}
local downloadQueue = {}

function imgurQueue.new()
    return {coroutines = {}}
end

function imgurQueue.enqueue(func, ...)
    local co = coroutine.create(func)
    table.insert(downloadQueue.coroutines, {co = co, args = {...}})
end

function imgurQueue.process()
    if downloadQueue.processing then return end
    downloadQueue.processing = true

    while table.Count(downloadQueue.coroutines) >= 0 do
        if table.Count(downloadQueue.coroutines) == 0 then
            downloadQueue.processing = false
            return
        end

        local coroutineData = table.remove(downloadQueue.coroutines, 1)
        local co, args = coroutineData.co, coroutineData.args
        local success, _ = coroutine.resume(co, unpack(args))

        if success and coroutine.status(co) == "suspended" then
            table.insert(downloadQueue.coroutines, coroutineData)
        end
    end
end

file.CreateDir("pixel")

local function downloadIcon(data)
    local id = data[1]
    local callback = data[2]

    if materials[id] then return callback(materials[id]) end

    local useproxy = data[3]
    local matSettings = data[4]

    if file.Exists("pixel/" .. id .. ".png", "DATA") then
        materials[id] = Material("../data/pixel/" .. id .. ".png", matSettings or "noclamp smooth mips")
        return callback(materials[id])
    end

    http.Fetch((useproxy and "https://proxy.duckduckgo.com/iu/?u=https://i.imgur.com/" or "https://i.imgur.com/") .. id .. ".png",
        function(body, len, headers, code)
            if len > 2097152 then
                materials[id] = Material("nil")
                return callback(materials[id])
            end

            file.Write("pixel/" .. id .. ".png", body)
            materials[id] = Material("../data/pixel/" .. id .. ".png", matSettings or "noclamp smooth mips")

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

function PIXEL.GetImgur(id, callback, useproxy, matSettings)
    if materials[id] then return callback(materials[id]) end
    imgurQueue.enqueue(downloadIcon, { id, callback, useproxy, matSettings })

    imgurQueue.process()
end