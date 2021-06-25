
PIXEL.UI.Overrides = PIXEL.UI.Overrides or {}

--Creates a function that can be used to conditionally detour a function depending on function that should be called before.
--@tparam func the method to call if the override is not enabled
--@tparam func the method to call if the override is enabled
--@tparam func a method that returns a boolean that determines whether the override should be ran or not
--@treturn func a method with a toggleable override
function PIXEL.UI.CreateToggleableOverride(method, override, toggleGetter)
    return function(...)
        return toggleGetter(...) and override(...) or method(...)
    end
end

local overridePopupsCvar = CreateClientConVar("pixel_ui_override_popups", (PIXEL.OverrideDermaMenus > 1) and "1" or "0", true, false, "Should the default derma popups be restyled with PIXEL UI?", 0, 1)

--Determines whether or not the default derma popups should be overriden based on the user and server preferences.
--@treturn bool whether to enable the derma popup override or not
function PIXEL.UI.ShouldOverrideDermaPopups()
    local overrideSetting = PIXEL.OverrideDermaMenus

    if not overrideSetting or overrideSetting == 0 then return false end
    if overrideSetting == 3 then return true end

    return overridePopupsCvar:GetBool()
end
