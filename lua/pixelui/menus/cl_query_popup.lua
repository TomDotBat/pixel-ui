
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

    self.BottomPanel = vgui.Create("Panel", self)
    self.ButtonHolder = vgui.Create("Panel", self.BottomPanel)

    self.Buttons = {}
end

function PANEL:AddOption(name, callback)
    callback = callback or function() end

    local btn = vgui.Create("PIXEL.TextButton", self.ButtonHolder)
    btn:SetText(name)
    btn.DoClick = function()
        self:Close(true)
        callback()
    end
    table.insert(self.Buttons, btn)
end

function PANEL:LayoutContent(w, h)
    self.Message:SetSize(self.Message:CalculateSize())
    self.Message:Dock(TOP)
    self.Message:DockMargin(0, 0, 0, PIXEL.Scale(8))

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

    if self.BottomPanel:GetWide() < self.ButtonHolder:GetWide() then
        self.BottomPanel:SetWide(self.ButtonHolder:GetWide())
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

vgui.Register("PIXEL.Query", PANEL, "PIXEL.Frame")

function Derma_Query(text, title, ...)
    local msg = vgui.Create("PIXEL.Query")
    msg:SetTitle(title)
    msg:SetText(text)

    local args = {...}
    for i = 1, #args, 2 do
        msg:AddOption(args[i], args[i + 1])
    end

    msg:MakePopup()
    msg:DoModal()

    return msg
end