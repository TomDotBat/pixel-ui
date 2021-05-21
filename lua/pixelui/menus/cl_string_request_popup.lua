
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

    self.TextEntry = vgui.Create("PIXEL.TextEntry", self)

    self.BottomPanel = vgui.Create("Panel", self)
    self.ButtonHolder = vgui.Create("Panel", self.BottomPanel)

    self.Buttons = {}
end

function PANEL:AddOption(name, callback)
    local btn = vgui.Create("PIXEL.TextButton", self.ButtonHolder)
    btn:SetText(name)
    btn.DoClick = function()
        self:Close(true)
        callback(self.TextEntry:GetValue())
    end
    table.insert(self.Buttons, btn)
end

function PANEL:LayoutContent(w, h)
    self.Message:SetSize(self.Message:CalculateSize())
    self.Message:Dock(TOP)
    self.Message:DockMargin(0, 0, 0, PIXEL.Scale(8))

    self.TextEntry:SetTall(PIXEL.Scale(32))
    self.TextEntry:Dock(TOP)
    self.TextEntry:DockMargin(0, 0, 0, PIXEL.Scale(10))

    for k,v in ipairs(self.Buttons) do
        v:SizeToText()
        v:Dock(LEFT)
        v:DockMargin(PIXEL.Scale(4), 0, PIXEL.Scale(4), 0)
    end

    self.ButtonHolder:SizeToChildren(true)

    local firstBtn = self.Buttons[1]

    self.BottomPanel:Dock(TOP)
    self.BottomPanel:SetTall(firstBtn:GetTall())
    self.ButtonHolder:SetTall(firstBtn:GetTall())

    self.ButtonHolder:CenterHorizontal()

    if self.ButtonHolder:GetWide() < firstBtn:GetWide() then
        self.ButtonHolder:SetWide(firstBtn:GetWide())
    end

    if self:GetWide() < PIXEL.Scale(240) then
        self:SetWide(240)
        self:Center()
    end

    if self.HasSized and self.HasSized > 1 then return end
    self.HasSized = (self.HasSized or 0) + 1

    self:SizeToChildren(true, true)
    self:Center()
end

function PANEL:SetText(text) self.Message:SetText(text) end
function PANEL:GetText(text) return self.Message:GetText() end

function PANEL:SetPlaceholderText(text) self.TextEntry:SetPlaceholderText(text) end
function PANEL:GetPlaceholderText(text) return self.TextEntry:GetPlaceholderText() end

vgui.Register("PIXEL.StringRequest", PANEL, "PIXEL.Frame")

function Derma_StringRequest(title, text, placeholderText, enterCallback, cancelCallback, buttonText, cancelText)
    cancelCallback = cancelCallback or function() end
    buttonText = buttonText or "OK"
    cancelText = cancelText or "Cancel"

    local msg = vgui.Create("PIXEL.StringRequest")
    msg:SetTitle(title)
    msg:SetText(text)

    msg:SetPlaceholderText(placeholderText)

    msg:AddOption(buttonText, enterCallback)
    msg:AddOption(cancelText, cancelCallback)

    msg.CloseButton.DoClick = function(s)
        cancelCallback(msg.TextEntry:GetValue())
        msg:Close()
    end

    msg:MakePopup()
    msg:DoModal()

    return msg
end