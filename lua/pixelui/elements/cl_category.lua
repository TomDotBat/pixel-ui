
local PANEL = {}

AccessorFunc(PANEL, "Title", "Title", FORCE_STRING)

PIXEL.RegisterFont("UI.CategoryHeader", "Open Sans Bold", 19)

function PANEL:Init()
    self.ArrowRotation = 0

    self.BackgroundCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 6)
end

function PANEL:DoClick()
    self:GetParent():Toggle()
end

local lerp = Lerp
function PANEL:Paint(w, h)
    PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, self.BackgroundCol)
    PIXEL.DrawSimpleText(self.Title, "UI.CategoryHeader", PIXEL.Scale(10), h / 2, PIXEL.Colors.PrimaryText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    self.ArrowRotation = lerp(FrameTime() * 10, self.ArrowRotation, self:GetParent():GetExpanded() and 0 or 90)

    local arrowSize = h * .45
    PIXEL.DrawImgurRotated(w - h * .3 - PIXEL.Scale(4), h / 2, arrowSize, arrowSize, self.ArrowRotation, "30Bvuwi", PIXEL.Colors.PrimaryText)
end

vgui.Register("PIXEL.CategoryHeader", PANEL, "PIXEL.Button")

PANEL = {}

AccessorFunc(PANEL, "m_bSizeExpanded", "Expanded", FORCE_BOOL)
AccessorFunc(PANEL, "m_iContentHeight", "StartHeight")
AccessorFunc(PANEL, "m_fAnimTime", "AnimTime")
AccessorFunc(PANEL, "m_bDrawBackground", "PaintBackground", FORCE_BOOL)
AccessorFunc(PANEL, "m_iPadding", "Padding")
AccessorFunc(PANEL, "m_pList", "List")

function PANEL:Init()
    self.Header = vgui.Create("PIXEL.CategoryHeader", self)

    self:SetTitle("PIXEL Category")

    self:SetExpanded(true)
    self:SetMouseInputEnabled(true)

    self:SetAnimTime(0.2)
    self.SlideAnimation = Derma_Anim("Anim", self, self.AnimSlide)

    self.BackgroundCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 2)
end

function PANEL:UnselectAll()
    local children = self:GetChildren()
    for k, v in pairs(children) do
        if v.SetSelected then
            v:SetSelected(false)
        end
    end
end

function PANEL:Think()
    self.SlideAnimation:Run()
end

function PANEL:SetTitle(title)
    self.Header:SetTitle(title)
end

function PANEL:Paint(w, h)
    PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, self.BackgroundCol)
end

function PANEL:SetContents(contents)
    self.Contents = contents
    self.Contents:SetParent(self)
    self.Contents:Dock(FILL)

    local margin = PIXEL.Scale(8)
    self.Contents:DockMargin(margin, margin, margin, margin)

    if not self:GetExpanded() then
        self.OldHeight = self:GetTall()
    elseif self:GetExpanded() and IsValid(self.Contents) and self.Contents:GetTall() < 1 then
        self.Contents:SizeToChildren(false, true)
        self.OldHeight = self.Contents:GetTall()
        self:SetTall(self.OldHeight)
    end

    self:InvalidateLayout(true)
end

function PANEL:SetExpanded(expanded)
    self.m_bSizeExpanded = tobool(expanded)

    if not self:GetExpanded() then
        if not self.SlideAnimation.Finished and self.OldHeight then return end
        self.OldHeight = self:GetTall()
    end
end

function PANEL:Toggle()
    self:SetExpanded(not self:GetExpanded())

    self.SlideAnimation:Start(self:GetAnimTime(), {From = self:GetTall()})

    self:InvalidateLayout(true)

    self:OnToggle(self:GetExpanded())
end

function PANEL:OnToggle(expanded) end

function PANEL:DoExpansion(b)
    if self:GetExpanded() == b then return end
    self:Toggle()
end

function PANEL:LayoutContent(w, h) end

function PANEL:PerformLayout(w, h)
    self.Header:Dock(TOP)
    self.Header:SetTall(PIXEL.Scale(26))

    if IsValid(self.Contents) then
        if self:GetExpanded() then
            self.Contents:InvalidateLayout(true)
            self.Contents:SetVisible(true)
        else
            self.Contents:SetVisible(false)
        end
    end

    if self:GetExpanded() then
        if IsValid(self.Contents) and #self.Contents:GetChildren() > 0 then self.Contents:SizeToChildren(false, true) end
        self:SizeToChildren(false, true)
    else
        if IsValid(self.Contents) and not self.OldHeight then self.OldHeight = self.Contents:GetTall() end
        self:SetTall(self.Header:GetTall())
    end

    self.SlideAnimation:Run()

    self:LayoutContent(w, h)
end

function PANEL:OnMousePressed(mcode)
    if not self:GetParent().OnMousePressed then return end
    return self:GetParent():OnMousePressed(mcode)
end

function PANEL:AnimSlide(anim, delta, data)
    self:InvalidateLayout()
    self:InvalidateParent()

    if anim.Started then
        if not IsValid(self.Contents) and (self.OldHeight or 0) < self.Header:GetTall() then
            self.OldHeight = 0
            for id, pnl in pairs(self:GetChildren()) do
                self.OldHeight = self.OldHeight + pnl:GetTall()
            end
        end

        if self:GetExpanded() then
            data.To = math.max(self.OldHeight, self:GetTall())
        else
            data.To = self:GetTall()
        end
    end

    if IsValid(self.Contents) then self.Contents:SetVisible(true) end

    self:GetParent():InvalidateLayout()
    self:GetParent():GetParent():InvalidateLayout()

    self:SetTall(Lerp(delta, data.From, data.To))
end

vgui.Register("PIXEL.Category", PANEL, "Panel")