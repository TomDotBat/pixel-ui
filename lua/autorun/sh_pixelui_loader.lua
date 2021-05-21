
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