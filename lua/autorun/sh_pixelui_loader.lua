
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

PIXEL = PIXEL or {}
PIXEL.UI = PIXEL.UI or {}
PIXEL.UI.Version = "1.2.0"

local function loadDirectory(dir)
	local fil, fol = file.Find(dir .. "/*", "LUA")

	for k,v in ipairs(fil) do
		local dirs = dir .. "/" .. v

		if v:StartWith("cl_") then
			if SERVER then AddCSLuaFile(dirs)
			else include(dirs) end
		elseif v:StartWith("sh_") then
			AddCSLuaFile(dirs)
			include(dirs)
		else
			if SERVER then include(dirs) end
		end
	end

	for k,v in pairs(fol) do
		loadDirectory(dir .. "/" .. v)
	end
end

loadDirectory("pixelui")

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
