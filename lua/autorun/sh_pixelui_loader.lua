
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

--PIXEL UI
--A modern, optimised UI library to replace derma and other slow built in Garry's Mod functions.
--@module pixel-ui
--@author Tom (Tom.bat) O'Sullivan
--@license GPL-3.0
--@copyright Tom O'Sullivan 2021

PIXEL = PIXEL or {}
PIXEL.UI = PIXEL.UI or {}
PIXEL.UI.Version = "1.2.3"

--Loads an entire Lua directory.
--Will only AddCSLuaFile() files prefixed with "cl_" or "sh_", otherwise it will be considered serverside only.
--@tparam string the path of the directory you want to load
--@treturn {string,...} the names of the files found within the target directory
--@treturn {string,...} the names of the folders found within the target directory
function PIXEL.LoadDirectory(path)
	local files, folders = file.Find(path .. "/*", "LUA")

	for _, fileName in ipairs(files) do
		local filePath = path .. "/" .. fileName

		if CLIENT then
			include(filePath)
		else
			if fileName:StartWith("cl_") then
				AddCSLuaFile(filePath)
			elseif fileName:StartWith("sh_") then
				AddCSLuaFile(filePath)
				include(filePath)
			else
				include(filePath)
			end
		end
	end

	return files, folders
end

--Recursively loads a Lua directory.
--@tparam string the base path of which the recursive loader should start in
--@see PIXEL.LoadDirectory
function PIXEL.LoadDirectoryRecursive(basePath)
	local _, folders = PIXEL.LoadDirectory(basePath)
	for _, folderName in ipairs(folders) do
		PIXEL.LoadDirectoryRecursive(basePath .. "/" .. folderName)
	end
end

PIXEL.LoadDirectoryRecursive("pixelui")

hook.Run("PIXEL.UI.FullyLoaded")

if CLIENT then return end

resource.AddWorkshop("2468112758")

hook.Add("Think", "PIXEL.UI.VersionChecker", function()
	hook.Remove("Think", "PIXEL.UI.VersionChecker")

	http.Fetch("https://raw.githubusercontent.com/TomDotBat/pixel-ui/master/VERSION", function(body)
		if PIXEL.UI.Version ~= string.Trim(body) then
			local red = Color(192, 27, 27)

			MsgC(red, "[PIXEL UI] There is an update available, please download it at: https://github.com/TomDotBat/pixel-ui/releases\n")
			MsgC(red, "\nYour version: " .. PIXEL.UI.Version .. "\n")
			MsgC(red, "New  version: " .. body .. "\n")
			return
		end
	end)
end)