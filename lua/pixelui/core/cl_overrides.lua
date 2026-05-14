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

PIXEL.UI.Overrides = PIXEL.UI.Overrides or {}

--- Creates a wrapper that swaps between an override and the original method.
---@param method fun(...): any Original method to call when override is disabled.
---@param override fun(...): any Override method to call when enabled.
---@param toggleGetter fun(...): boolean Callback that returns true when override should run.
---@return fun(...): any Wrapper function that dispatches based on toggleGetter.
function PIXEL.UI.CreateToggleableOverride(method, override, toggleGetter)
    return function(...)
        return toggleGetter(...) and override(...) or method(...)
    end
end

local overridePopupsCvar = CreateClientConVar("pixel_ui_override_popups", (PIXEL.OverrideDermaMenus > 1) and "1" or "0", true, false, "Should the default derma popups be restyled with PIXEL UI?", 0, 1)
--- Returns whether PIXEL UI should override Derma popups.
---@return boolean enabled True when popup overrides are active.
function PIXEL.UI.ShouldOverrideDermaPopups()
    local overrideSetting = PIXEL.OverrideDermaMenus

    if not overrideSetting or overrideSetting == 0 then return false end
    if overrideSetting == 3 then return true end

    return overridePopupsCvar:GetBool()
end
