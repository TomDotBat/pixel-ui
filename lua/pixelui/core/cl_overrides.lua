
PIXEL.UI.Overrides = PIXEL.UI.Overrides or {}

function PIXEL.UI.CreateToggleableOverride(method, override, toggleGetter)
    return function(...)
        return toggleGetter(...) and override(...) or method(...)
    end
end

local overridePopupsCvar = CreateClientConVar("pixel_ui_override_popups", (PIXEL.OverrideDermaMenus > 1) and "1" or "0", true, false, "Should the default derma popups be restyled with PIXEL UI?", 0, 1)
function PIXEL.UI.ShouldOverrideDermaPopups()
    local overrideSetting = PIXEL.OverrideDermaMenus

    if not overrideSetting or overrideSetting == 0 then return false end
    if overrideSetting == 3 then return true end

    return overridePopupsCvar:GetBool()
end