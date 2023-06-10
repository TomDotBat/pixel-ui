--[[
	PIXEL UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local PANEL = {}

AccessorFunc(PANEL, "Name", "Name", FORCE_STRING)
AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING)
AccessorFunc(PANEL, "DrawOutline", "DrawOutline", FORCE_BOOL)

PIXEL.RegisterFont("SidebarItem", "Open Sans Bold", 19)

function PANEL:Init()
    self:SetName("N/A")
    self:SetDrawOutline(true)

    self.TextCol = PIXEL.CopyColor(PIXEL.Colors.SecondaryText)
    self.BackgroundCol = PIXEL.CopyColor(PIXEL.Colors.Transparent)
    self.BackgroundHoverCol = ColorAlpha(PIXEL.Colors.Scroller, 80)
end

function PANEL:Paint(w, h)
    local textCol = PIXEL.Colors.SecondaryText
    local backgroundCol = PIXEL.Colors.Transparent

    if self:IsHovered() then
        textCol = PIXEL.Colors.PrimaryText
        backgroundCol = self.BackgroundHoverCol
    end

    if self:IsDown() or self:GetToggle() then
        textCol = PIXEL.Colors.PrimaryText
        backgroundCol = self.BackgroundHoverCol
    end

    local animTime = FrameTime() * 12
    self.TextCol = PIXEL.LerpColor(animTime, self.TextCol, textCol)
    self.BackgroundCol = PIXEL.LerpColor(animTime, self.BackgroundCol, backgroundCol)

    if self:GetDrawOutline() then PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, self.BackgroundCol, PIXEL.Scale(1)) end

    local imgurID = self:GetImgurID()
    if imgurID then
        local iconSize = h * .65
        PIXEL.DrawImgur(PIXEL.Scale(10), (h - iconSize) / 2, iconSize, iconSize, imgurID, self.TextCol)
        PIXEL.DrawSimpleText(self:GetName(), "SidebarItem", PIXEL.Scale(20) + iconSize, h / 2, self.TextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        return
    end

    PIXEL.DrawSimpleText(self:GetName(), "SidebarItem", PIXEL.Scale(10), h / 2, self.TextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.SidebarItem", PANEL, "PIXEL.Button")

PANEL = {}

AccessorFunc(PANEL, "ImgurID", "ImgurID", FORCE_STRING)
AccessorFunc(PANEL, "ImgurScale", "ImgurScale", FORCE_NUMBER)
AccessorFunc(PANEL, "ImgurOffset", "ImgurOffset", FORCE_NUMBER)
AccessorFunc(PANEL, "ButtonOffset", "ButtonOffset", FORCE_NUMBER)

function PANEL:Init()
    self.Items = {}

    self.Scroller = vgui.Create("PIXEL.ScrollPanel", self)
    self.Scroller:SetBarDockShouldOffset(true)
    self.Scroller.LayoutContent = function(s, w, h)
        local spacing = PIXEL.Scale(8)
        local height = PIXEL.Scale(35)
        for k,v in pairs(self.Items) do
            v:SetTall(height)
            v:Dock(TOP)
            v:DockMargin(0, 0, 0, spacing)
        end
    end

    self:SetImgurScale(.6)
    self:SetImgurOffset(0)
    self:SetButtonOffset(0)

    self.BackgroundCol = PIXEL.CopyColor(PIXEL.Colors.Header)
end

function PANEL:AddItem(id, name, imgurID, doClick, order)
    local btn = vgui.Create("PIXEL.SidebarItem", self.Scroller)

    btn:SetZPos(order or table.Count(self.Items) + 1)
    btn:SetName(name)
    if imgurID then btn:SetImgurID(imgurID) end
    btn.Function = doClick

    btn.DoClick = function(s)
        self:SelectItem(id)
    end

    self.Items[id] = btn

    return btn
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
    local sideSpacing = PIXEL.Scale(7)
    local topSpacing = PIXEL.Scale(7)
    self:DockPadding(sideSpacing, self:GetImgurID() and w * self:GetImgurScale() + self:GetImgurOffset() + self:GetButtonOffset() + topSpacing * 2 or topSpacing, sideSpacing, topSpacing)

    self.Scroller:Dock(FILL)
    self.Scroller:GetCanvas():DockPadding(0, 0, self.Scroller.VBar.Enabled and sideSpacing or 0, 0)
end

function PANEL:Paint(w, h)
    PIXEL.DrawRoundedBoxEx(PIXEL.Scale(6), 0, 0, w, h, self.BackgroundCol, false, false, true)

    local imgurID = self:GetImgurID()
    if imgurID then
        local imageSize = w * self:GetImgurScale()
        PIXEL.DrawImgur((w - imageSize) / 2, self:GetImgurOffset() + PIXEL.Scale(15), imageSize, imageSize, imgurID, color_white)
    end
end

vgui.Register("PIXEL.Sidebar", PANEL, "Panel")