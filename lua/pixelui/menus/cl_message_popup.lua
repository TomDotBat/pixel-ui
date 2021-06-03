
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

local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "ButtonText", "ButtonText", FORCE_STRING)

PIXEL.RegisterFont("UI.Message", "Open Sans SemiBold", 18)

function PANEL:Init()
    self:SetDraggable(true)
    self:SetSizable(true)

    self:SetMinWidth(PIXEL.Scale(240))
    self:SetMinHeight(PIXEL.Scale(80))

    self.Message = vgui.Create("PIXEL.Label", self)
    self.Message:SetTextAlign(TEXT_ALIGN_CENTER)
    self.Message:SetFont("UI.Message")

    self.ButtonHolder = vgui.Create("Panel", self)

    self.Button = vgui.Create("PIXEL.TextButton", self.ButtonHolder)
    self.Button.DoClick = function(s, w, h)
        self:Close(true)
    end
end

function PANEL:LayoutContent(w, h)
    self.Message:SetSize(self.Message:CalculateSize())
    self.Message:Dock(TOP)
    self.Message:DockMargin(0, 0, 0, PIXEL.Scale(8))

    self.Button:SizeToText()
    self.ButtonHolder:Dock(TOP)
    self.ButtonHolder:SetTall(self.Button:GetTall())
    self.Button:CenterHorizontal()

    if self.ButtonHolder:GetWide() < self.Button:GetWide() then
        self.ButtonHolder:SetWide(self.Button:GetWide())
    end

    if self:GetWide() < PIXEL.Scale(240) then
        self:SetWide(PIXEL.Scale(240))
        self:Center()
    end

    if self.HasSized and self.HasSized > 1 then return end
    self.HasSized = (self.HasSized or 0) + 1

    self:SizeToChildren(true, true)
    self:Center()
end

function PANEL:SetText(text) self.Message:SetText(text) end
function PANEL:GetText(text) return self.Message:GetText() end

function PANEL:SetButtonText(text) self.Button:SetText(text) end
function PANEL:GetButtonText(text) return self.Button:GetText() end

vgui.Register("PIXEL.Message", PANEL, "PIXEL.Frame")

PIXEL.UI.Overrides.Derma_Message = PIXEL.UI.Overrides.Derma_Message or Derma_Message

Derma_Message = PIXEL.UI.CreateToggleableOverride(PIXEL.UI.Overrides.Derma_Message, function(text, title, buttonText)
    buttonText = buttonText or "OK"

    local msg = vgui.Create("PIXEL.Message")
    msg:SetTitle(title)
    msg:SetText(text)
    msg:SetButtonText(buttonText)

    msg:MakePopup()
    msg:DoModal()

    return msg
end, PIXEL.UI.ShouldOverrideDermaPopups)