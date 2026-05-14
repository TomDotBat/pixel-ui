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

--- PIXEL scroll panel with custom scrollbar.
---@class PIXEL.ScrollPanel : DPanel
local PANEL = {}

AccessorFunc(PANEL, "Padding",   "Padding")
AccessorFunc(PANEL, "Canvas", "Canvas")
AccessorFunc(PANEL, "ScrollbarLeft", "ScrollbarLeftSide")
AccessorFunc(PANEL, "BarDockShouldOffset", "BarDockShouldOffset", FORCE_BOOL)

function PANEL:Init()
    self.Canvas = vgui.Create("Panel", self)
    self.Canvas.OnMousePressed = function(s, code) s:GetParent():OnMousePressed(code) end
    self.Canvas:SetMouseInputEnabled(true)
    self.Canvas.PerformLayout = function(pnl)
        self:PerformLayout()
        self:InvalidateParent()
    end

    self.VBar = vgui.Create("PIXEL.Scrollbar", self)
    self.VBar:Dock(RIGHT)

    self:SetPadding(0)
    self:SetMouseInputEnabled(true)

    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)

    self.ScrollDelta = 0
    self.ScrollReturnWait = 0

    self:SetBarDockShouldOffset(true)
    self.VBar:SetWide(PIXEL.Scale(8))

    self.Canvas.PerformLayout = function(s, w, h)
        self:LayoutContent(w, h)
    end
end

--- Adds a child panel into the scroll canvas.
---@param pnl Panel Child panel to add.
function PANEL:AddItem(pnl)
    pnl:SetParent(self:GetCanvas())
end

function PANEL:OnChildAdded(child)
    self:AddItem(child)
end

function PANEL:SizeToContents()
    self:SetSize(self.Canvas:GetSize())
end

--- Returns the vertical scrollbar panel.
---@return PIXEL.Scrollbar vbar Vertical scrollbar instance.
function PANEL:GetVBar()
    return self.VBar
end

--- Returns the internal canvas panel.
---@return Panel canvas Canvas panel.
function PANEL:GetCanvas()
    return self.Canvas
end

--- Returns the inner canvas width.
---@return number width Canvas width.
function PANEL:InnerWidth()
    return self:GetCanvas():GetWide()
end

--- Rebuilds canvas bounds from its children.
function PANEL:Rebuild()
    self:GetCanvas():SizeToChildren(false, true)

    if self.m_bNoSizing and self:GetCanvas():GetTall() < self:GetTall() then
        self:GetCanvas():SetPos(0, (self:GetTall() - self:GetCanvas():GetTall()) * 0.5)
    end
end

function PANEL:Think()
    if not self.lastThink then self.lastThink = CurTime() end
    local elapsed = CurTime() - self.lastThink
    self.lastThink = CurTime()

    if self.ScrollDelta > 0 then
        self.VBar:OnMouseWheeled(self.ScrollDelta / 1)

        if self.VBar.Scroll >= 0 then
            self.ScrollDelta = self.ScrollDelta - 10 * elapsed
        end
        if self.ScrollDelta < 0 then self.ScrollDelta = 0 end
    elseif self.ScrollDelta < 0 then
        self.VBar:OnMouseWheeled(self.ScrollDelta / 1)

        if self.VBar.Scroll <= self.VBar.CanvasSize then
            self.ScrollDelta = self.ScrollDelta + 10 * elapsed
        end
        if self.ScrollDelta > 0 then self.ScrollDelta = 0 end
    end

    if self.ScrollReturnWait >= 1 then
        if self.VBar.Scroll < 0 then
            if self.VBar.Scroll <= -75 and self.ScrollDelta > 0 then self.ScrollDelta = self.ScrollDelta / 2 end

            self.ScrollDelta = self.ScrollDelta + (self.VBar.Scroll / 1500 - 0.01) * 100 * elapsed

        elseif self.VBar.Scroll > self.VBar.CanvasSize then
            if self.VBar.Scroll >= self.VBar.CanvasSize + 75 and self.ScrollDelta < 0 then self.ScrollDelta = self.ScrollDelta / 2 end

            self.ScrollDelta = self.ScrollDelta + ((self.VBar.Scroll - self.VBar.CanvasSize) / 1500 + 0.01) * 100 * elapsed
        end
    else
        self.ScrollReturnWait = self.ScrollReturnWait + 10 * elapsed
    end
end

function PANEL:OnMouseWheeled(delta)
    if (delta > 0 and self.VBar.Scroll <= self.VBar.CanvasSize * 0.005) or
            (delta < 0 and self.VBar.Scroll >= self.VBar.CanvasSize * 0.995) then
        self.ScrollDelta = self.ScrollDelta + delta / 10
        return
    end

    self.ScrollDelta = delta / 2
    self.ScrollReturnWait = 0
end

--- Called when the scrollbar offset changes.
---@param iOffset number Scroll offset.
function PANEL:OnVScroll(iOffset)
    self.Canvas:SetPos(0, iOffset)
end

--- Scrolls so a child panel is brought into view.
---@param panel Panel Child panel to center.
function PANEL:ScrollToChild(panel)
    self:PerformLayout()

    local y = select(2, self.Canvas:GetChildPosition(panel)) + select(2, panel:GetSize()) * 0.5;
    y = y - self:GetTall() * 0.5;

    self.VBar:AnimateTo(y, 0.5, 0, 0.5);
end

--- Extension point for laying out canvas children.
---@param w number Canvas width.
---@param h number Canvas height.
function PANEL:LayoutContent(w, h) end

function PANEL:PerformLayout(w, h)
    if self:GetScrollbarLeftSide() then
        self.VBar:Dock(LEFT)
    else
        self.VBar:Dock(RIGHT)
    end

    local wide = self:GetWide()
    local xPos = 0
    local yPos = 0

    self:Rebuild()

    self.VBar:SetUp(self:GetTall(), self.Canvas:GetTall())
    yPos = self.VBar:GetOffset()

    if self.VBar.Enabled or not self:GetBarDockShouldOffset() then
        wide = wide - self.VBar:GetWide()

        if self:GetScrollbarLeftSide() then
            xPos = self.VBar:GetWide()
        end
    end

    self.Canvas:SetPos(xPos, yPos)
    self.Canvas:SetWide(wide)

    self:Rebuild()
end

--- Clears all canvas children.
---@return any result Result from Panel:Clear.
function PANEL:Clear()
    return self.Canvas:Clear()
end

function PANEL:Paint(w, h) end

vgui.Register("PIXEL.ScrollPanel", PANEL, "DPanel")
