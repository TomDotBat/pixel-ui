--[[
	PIXEL UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local materials = {}
local queue = {}

local useProxy = false

file.CreateDir("pixel")

local function processQueue()
    if queue[1] then
        local url, matSettings, callback = unpack(queue[1])

        local filePath = "pixel/" .. url
        url = "https://" .. url

        http.Fetch((useProxy and ("https://proxy.duckduckgo.com/iu/?u=" .. url)) or url,
            function(body, len, headers, code)
                if len > 2097152 then
                    materials[filePath] = Material("nil")
                else
                    file.Write(filePath, body)
                    materials[filePath] = Material("../data/" .. filePath, matSettings or "noclamp smooth mips")
                end

                callback(materials[filePath])
            end,
            function(error)
                if useProxy then
                    materials[filePath] = Material("nil")
                    callback(materials[filePath])
                else
                    useProxy = true
                    processQueue()
                end
            end
        )
    end
end

function PIXEL.GetImage(url, callback, matSettings)
    url = string.gsub(url, "https://", "")
    url = string.gsub(url, "http://", "")
    local urlExploded = string.Explode("/", url)
    local fileName = urlExploded[#urlExploded]
    local urlNoFile = string.sub(url, 1, url:find("/[^/]+$") - 1)

    local dirPath = "pixel/" .. urlNoFile
    local filePath = dirPath .. "/" .. fileName

    file.CreateDir(dirPath)

    if materials[filePath] then
        callback(materials[filePath])
    elseif file.Exists(filePath, "DATA") then
        materials[filePath] = Material("../data/" .. filePath, matSettings or "noclamp smooth mips")
        callback(materials[filePath])
    else
        table.insert(queue, {
            url,
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


-- Backwards compatibility for Imgur function
function PIXEL.GetImgur(id, callback, _, matSettings)
    local url = "i.imgur.com/" .. id .. ".png"
    PIXEL.GetImage(url, callback, matSettings)
end