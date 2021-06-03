
PIXEL.UI.Overrides = PIXEL.UI.Overrides or {}

function PIXEL.UI.CreateToggleableOverride(method, override, toggleGetter)
    return function(...)
        return toggleGetter(...) and override(...) or method(...)
    end
end

local overridePopupsCvar = CreateClientConVar("pixel_ui_override_popups", "0", true, false, "Should the default derma popups be restyled with PIXEL UI?", 0, 1)
function PIXEL.UI.ShouldOverrideDermaPopups()
    return overridePopupsCvar:GetBool()
end