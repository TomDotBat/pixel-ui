
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

local version = 1

PIXEL = PIXEL or {}
PIXEL.UI = PIXEL.UI or {
	Version = version
}

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

hook.Add("Think", "PIXEL.UI.UpdateChecker", function()
	hook.Remove("Think", "PIXEL.UI.UpdateChecker")
	http.Fetch("https://raw.githubusercontent.com/TomDotBat/pixel-ui/master/VERSION", function(bod)
		local v = tonumber(bod)
		if v ~= version then
			print("\n[PIXEL / UI] Update Available! \nCurrent Version: " .. version .. " \nAvailable Version: " .. v .. "\n")
			return
		end
		print("\n[PIXEL / UI] Up To Date! (" .. version .. ")\n")
	end, function(err)
		print("\n[PIXEL / UI] Update Checker Failed! (" .. err .. ")\n")
	end )
end)