
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