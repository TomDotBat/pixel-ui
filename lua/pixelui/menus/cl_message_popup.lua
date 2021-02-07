
local PANEL = {}

AccessorFunc(PANEL, "Text", "Text", FORCE_STRING)
AccessorFunc(PANEL, "ButtonText", "ButtonText", FORCE_STRING)

PIXEL.RegisterFont("UI.Message", "Open Sans SemiBold", 18)

function PANEL:Init()
    self:SetDraggable(false)
    --self:SetShadow(true)

    self.Message = vgui.Create("PIXEL.Label", self)
    self.Message:SetTextAlign(TEXT_ALIGN_CENTER)
    self.Message:SetFont("PIXEL.UI.Message")

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

    self:SizeToChildren(true, true)
    self:Center()
end

function PANEL:SetText(text) self.Message:SetText(text) end
function PANEL:GetText(text) return self.Message:GetText() end

function PANEL:SetButtonText(text) self.Button:SetText(text) end
function PANEL:GetButtonText(text) return self.Button:GetText() end

vgui.Register("PIXEL.Message", PANEL, "PIXEL.Frame")

function Derma_Message(text, title, buttonText)
    buttonText = buttonText or "OK"

    local msg = vgui.Create("PIXEL.Message")
    msg:SetTitle(title)
    msg:SetText(text)
    msg:SetButtonText(buttonText)

    msg:MakePopup()
    msg:DoModal()

    return msg
end