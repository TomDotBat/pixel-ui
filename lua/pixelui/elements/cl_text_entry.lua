

local PANEL = {}

function PANEL:Init()
    self.TextEntry = vgui.Create("PIXEL.TextEntryInternal", self)

    self.DisabledCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 6)
    self.FocusedOutlineCol = PIXEL.Colors.PrimaryText

    self.OutlineCol = PIXEL.OffsetColor(PIXEL.Colors.Scroller, 10)
    self.InnerOutlineCol = PIXEL.CopyColor(PIXEL.Colors.Transparent)
end

function PANEL:PerformLayout(w, h)
    self.TextEntry:Dock(FILL)

    local xPad, yPad = PIXEL.Scale(4), PIXEL.Scale(8)
    self:DockPadding(xPad, yPad, xPad, yPad)
end

function PANEL:Paint(w, h)
    if not self:IsEnabled() then
        PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, self.DisabledCol)
        PIXEL.DrawSimpleText("Disabled", "PIXEL.UI.TextEntry", PIXEL.Scale(4), h / 2, PIXEL.Colors.SecondaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        return
    end

    if self:GetValue() == "" then
        PIXEL.DrawSimpleText(self:GetPlaceholderText() or "", "PIXEL.UI.TextEntry", PIXEL.Scale(10), h / 2, PIXEL.Colors.SecondaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local outlineThickness = PIXEL.Scale(1)
    PIXEL.DrawOutlinedRoundedBox(PIXEL.Scale(4), 0, 0, w, h, self.OutlineCol, outlineThickness)

    local col = PIXEL.Colors.Transparent

    if self:IsEditing() then
        col = self.FocusedOutlineCol
    end

    if self.OverrideCol then
        col = self.OverrideCol
    end

    self.InnerOutlineCol = PIXEL.LerpColor(FrameTime() * 8, self.InnerOutlineCol, col)

    PIXEL.DrawOutlinedRoundedBox(PIXEL.Scale(3), outlineThickness, outlineThickness, w - outlineThickness * 2, h - outlineThickness * 2, self.InnerOutlineCol, PIXEL.Scale(1))
end

function PANEL:OnChange() end
function PANEL:OnValueChange(value) end

function PANEL:IsEnabled() return self.TextEntry:IsEnabled() end
function PANEL:SetEnabled(enabled) self.TextEntry:SetEnabled(enabled) end

function PANEL:GetValue() return self.TextEntry:GetValue() end
function PANEL:SetValue(value) self.TextEntry:SetValue(value) end

function PANEL:IsMultiline() return self.TextEntry:IsMultiline() end
function PANEL:SetMultiline(isMultiline) self.TextEntry:SetMultiline(isMultiline) end

function PANEL:IsEditing() return self.TextEntry:IsEditing() end

function PANEL:GetEnterAllowed() return self.TextEntry:GetEnterAllowed() end
function PANEL:SetEnterAllowed(allow) self.TextEntry:SetEnterAllowed(allow) end

function PANEL:GetUpdateOnType() return self.TextEntry:GetUpdateOnType() end
function PANEL:SetUpdateOnType(enabled) self.TextEntry:SetUpdateOnType(enabled) end

function PANEL:GetNumeric() return self.TextEntry:GetNumeric() end
function PANEL:SetNumeric(enabled) self.TextEntry:SetNumeric(enabled) end

function PANEL:GetHistoryEnabled() return self.TextEntry:GetHistoryEnabled() end
function PANEL:SetHistoryEnabled(enabled) self.TextEntry:SetHistoryEnabled(enabled) end

function PANEL:GetTabbingDisabled() return self.TextEntry:GetTabbingDisabled() end
function PANEL:SetTabbingDisabled(disabled) self.TextEntry:SetTabbingDisabled(disabled) end

function PANEL:GetPlaceholderText() return self.TextEntry:GetPlaceholderText() end
function PANEL:SetPlaceholderText(text) self.TextEntry:SetPlaceholderText(text) end

function PANEL:GetInt() return self.TextEntry:GetInt() end
function PANEL:GetFloat() return self.TextEntry:GetFloat() end

function PANEL:IsEditing() return self.TextEntry:IsEditing() end
function PANEL:SetEditable(enabled) self.TextEntry:SetEditable(enabled) end

function PANEL:AllowInput(value) end
function PANEL:GetAutoComplete(txt) end

function PANEL:OnKeyCode(code) end
function PANEL:OnEnter() end

function PANEL:OnGetFocus() end
function PANEL:OnLoseFocus() end

vgui.Register("PIXEL.TextEntry", PANEL, "Panel")

if not IsValid(LocalPlayer()) then return end

if IsValid(testframe) then testframe:Remove() end
testframe = vgui.Create("PIXEL.Frame")
testframe:SetPos(100, 100)
testframe:SetSize(200, 200)
testframe:MakePopup()

local child = vgui.Create("PIXEL.TextEntry", testframe)
child:SetPos(10, 40)
child:SetSize(100, 30)
