
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

local scrH = ScrH
local max = math.max

--Returns a scaled number based on the user's resolution, based on 1080p.
--@tparam number the number to scale
--@treturn number the given number scaled depending on the user's resolution
function PIXEL.Scale(value)
    return max(value * (scrH() / 1080), 1)
end

local constants = {}
local scaledConstants = {}

--Registers an identifiable number to be automatically scaled on resolution changes.
--@tparam string an identifier for the number to be retreived with
--@tparam number the number to scale
function PIXEL.RegisterScaledConstant(varName, size)
    constants[varName] = size
    scaledConstants[varName] = PIXEL.Scale(size)
end

--Returns a scaled constant from the identifier given.
--@tparam string the identifier of the number to retreive
function PIXEL.GetScaledConstant(varName)
    return scaledConstants[varName]
end

hook.Add("OnScreenSizeChanged", "PIXEL.UI.UpdateScaledConstants", function()
    for varName, size in pairs(constants) do
        scaledConstants[varName] = PIXEL.Scale(size)
    end
end)
