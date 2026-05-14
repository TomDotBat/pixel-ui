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

local scrH = ScrH
local max = math.max
--- Scales a value based on screen height (min 1).
---@param value number
---@return number
function PIXEL.Scale(value)
    return max(value * (scrH() / 1080), 1)
end

local constants = {}
local scaledConstants = {}
--- Registers a constant that auto-scales on screen-size changes.
---@param varName string
---@param size number
function PIXEL.RegisterScaledConstant(varName, size)
    constants[varName] = size
    scaledConstants[varName] = PIXEL.Scale(size)
end

--- Returns the scaled value for a registered constant.
---@param varName string
---@return number|nil
function PIXEL.GetScaledConstant(varName)
    return scaledConstants[varName]
end

hook.Add("OnScreenSizeChanged", "PIXEL.UI.UpdateScaledConstants", function()
    for varName, size in pairs(constants) do
        scaledConstants[varName] = PIXEL.Scale(size)
    end
end)
