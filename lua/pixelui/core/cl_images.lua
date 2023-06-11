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

file.CreateDir(PIXEL.DownloadPath)

local function processQueue()
    if queue[1] then
        local url, filePath, matSettings, callback = unpack(queue[1])

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
    local urlWithoutProtocol = string.gsub(url, "https://", "")
    urlWithoutProtocol = string.gsub(urlWithoutProtocol, "http://", "")

    local fileName = url:match("[^/]+$")
    local urlWithoutFileName = string.sub(urlWithoutProtocol, 1, url:find("/[^/]+$") - 1)

    local dirPath = PIXEL.DownloadPath .. urlWithoutFileName
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
            filePath,
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


function PIXEL.GetImgur(id, callback, _, matSettings)
    local url = "i.imgur.com/" .. id .. ".png"
    PIXEL.GetImage(url, callback, matSettings)
end