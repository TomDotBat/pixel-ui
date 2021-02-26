
local PANEL = {}

AccessorFunc(PANEL, "Name", "Name", FORCE_STRING)

PIXEL.RegisterFont("UI.NavbarItem", "Open Sans SemiBold", 22)

function PANEL:Init()
    self:SetName("N/A")

    self.NormalCol = PIXEL.Colors.PrimaryText
    self.HoverCol = PIXEL.Colors.SecondaryText

    self.TextCol = PIXEL.CopyColor(self.NormalCol)
end

function PANEL:GetItemSize()
    PIXEL.SetFont("UI.NavbarItem")
    return PIXEL.GetTextSize(self:GetName())
end

function PANEL:Paint(w, h)
    local textCol = self.NormalCol

    if self:IsHovered() then
        textCol = self.HoverCol
    end

    local animTime = FrameTime() * 12
    self.TextCol = PIXEL.LerpColor(animTime, self.TextCol, textCol)

    PIXEL.DrawSimpleText(self:GetName(), "UI.NavbarItem", w / 2, h / 2, self.TextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.NavbarItem", PANEL, "PIXEL.Button")

PANEL = {}

function PANEL:Init()
    self.Items = {}

    self.SelectionX = 0
    self.SelectionW = 0

    self.BackgroundCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 10)
end

function PANEL:AddItem(id, name, doClick, order)
    local btn = vgui.Create("PIXEL.NavbarItem", self)

    btn:SetName(name:upper())
    btn.Order = order or table.Count(self.Items) + 1
    btn.Function = doClick

    btn.DoClick = function(s)
        self:SelectItem(id)
    end

    self.Items[id] = btn
end

function PANEL:RemoveItem(id)
    local item = self.Items[id]
    if not item then return end

    item:Remove()
    self.Items[id] = nil

    if self.SelectedItem != id then return end
    self:SelectItem(next(self.Items))
end

function PANEL:SelectItem(id)
    local item = self.Items[id]
    if not item then return end

    if self.SelectedItem and self.SelectedItem == id then return end
    self.SelectedItem = id

    for k,v in pairs(self.Items) do
        v:SetToggle(false)
    end

    item:SetToggle(true)
    item.Function(item)
end

function PANEL:PerformLayout(w, h)
    for k,v in pairs(self.Items) do
        v:Dock(LEFT)
        v:SetWide(v:GetItemSize() + PIXEL.Scale(30))
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(self.BackgroundCol)
    surface.DrawRect(0, 0, w, h)

    if not self.SelectedItem then
        self.SelectionX = Lerp(FrameTime() * 10, self.SelectionX, 0)
        self.SelectionW = Lerp(FrameTime() * 10, self.SelectionX, 0)
        return
    end

    local selectedItem = self.Items[self.SelectedItem]
    self.SelectionX = Lerp(FrameTime() * 10, self.SelectionX, selectedItem.x)
    self.SelectionW = Lerp(FrameTime() * 10, self.SelectionW, selectedItem:GetWide())

    local selectorH = PIXEL.Scale(3)
    surface.SetDrawColor(PIXEL.Colors.Primary)
    surface.DrawRect(self.SelectionX, h - selectorH, self.SelectionW, selectorH)
end

vgui.Register("PIXEL.Navbar", PANEL, "Panel")