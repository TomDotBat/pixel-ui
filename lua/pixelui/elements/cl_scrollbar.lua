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

--- PIXEL scrollbar grip.
---@class PIXEL.ScrollbarGrip : Panel
local PANEL = {}

function PANEL:Init()
    self.NormalCol = PIXEL.Colors.Scroller
    self.HoverCol = PIXEL.OffsetColor(self.NormalCol, 15)

    self.Colour = PIXEL.CopyColor(self.NormalCol)
end

function PANEL:OnMousePressed()
    self:GetParent():Grip(1)
end

function PANEL:Paint(w, h)
    self.Colour = PIXEL.LerpColor(FrameTime() * 12, self.Colour,
        (self:IsHovered() or self:GetParent().Dragging) and self.HoverCol or self.NormalCol
    )

    PIXEL.DrawRoundedBox(w / 2, 0, 0, w, h, self.Colour)
end

vgui.Register("PIXEL.ScrollbarGrip", PANEL, "Panel")

--- PIXEL vertical scrollbar control.
---@class PIXEL.Scrollbar : Panel
PANEL = {}

AccessorFunc(PANEL, "m_bVisibleFullHeight", "VisibleFullHeight", FORCE_BOOL)

function PANEL:Init()
    self.Offset = 0
    self.Scroll = 0
    self.CanvasSize = 1
    self.BarSize = 1

    self.BackgroundCol = PIXEL.OffsetColor(PIXEL.Colors.Background, 5)

    self.Scrollbar = vgui.Create("PIXEL.ScrollbarGrip", self)
    self:SetVisibleFullHeight(false)
end

--- Enables or disables the scrollbar.
---@param b boolean True to enable.
function PANEL:SetEnabled(b)
    if not b then
        self.Offset = 0
        self:SetScroll(0)
        self.HasChanged = true
    end

    self:SetMouseInputEnabled(b)

    if not self:GetVisibleFullHeight() then
        self:SetVisible(b)
    end

    if self.Enabled != b then
        self:GetParent():InvalidateLayout()

        if self:GetParent().OnScrollbarAppear then
            self:GetParent():OnScrollbarAppear()
        end
    end

    self.Enabled = b
end

--- Returns whether the scrollbar is enabled.
---@return boolean enabled True when enabled.
function PANEL:GetEnabled()
    return self.Enabled
end

--- Returns the legacy position field.
---@return number|nil value Legacy position value.
function PANEL:Value()
    return self.Pos
end

--- Returns the fractional size of the grip relative to content.
---@return number scale Scrollbar grip scale.
function PANEL:BarScale()
    if self.BarSize == 0 then return 1 end
    return self.BarSize / (self.CanvasSize + self.BarSize)
end

--- Configures viewport and canvas sizes for scrolling.
---@param barSize number Viewport height.
---@param canvasSize number Canvas content height.
function PANEL:SetUp(barSize, canvasSize)
    self.BarSize = barSize
    self.CanvasSize = math.max(canvasSize - barSize, 1)

    self:SetEnabled(canvasSize > barSize)

    self:InvalidateLayout()
end

--- Mouse wheel handler for the scrollbar.
---@param dlta number Mouse wheel delta.
---@return boolean handled Whether scroll value changed.
function PANEL:OnMouseWheeled(dlta)
    if not self:IsVisible() then return false end
    return self:AddScroll(dlta * -2)
end

--- Applies additional scroll delta.
---@param dlta number Scroll delta in wheel steps.
---@return boolean changed Whether scroll value changed.
function PANEL:AddScroll(dlta)
    local oldScroll = self:GetScroll()

    dlta = dlta * 25
    self:SetScroll(oldScroll + dlta)

    return oldScroll != self:GetScroll()
end

--- Sets the current scroll value.
---@param scrll number Target scroll amount.
function PANEL:SetScroll(scrll)
    if not self.Enabled then self.Scroll = 0 return end

    self.Scroll = math.Clamp(scrll, 0, self.CanvasSize + 75)

    self:InvalidateLayout()

    local func = self:GetParent().OnVScroll
    if func then
        func(self:GetParent(), self:GetOffset())
    else
        self:GetParent():InvalidateLayout()
    end
end

--- Soft-clamps scroll value to overscroll limits.
function PANEL:LimitScroll()
    if self.Scroll < 0 or self.Scroll > self.CanvasSize then
        self.Scroll = math.Clamp(self.Scroll, -75, self.CanvasSize + 75)
    end
end

--- Animates the scroll position to a target value.
---@param scrll number Target scroll value.
---@param length number Animation duration.
---@param delay number Animation delay.
---@param ease number Easing value.
function PANEL:AnimateTo(scrll, length, delay, ease)
    local anim = self:NewAnimation(length, delay, ease)
    anim.StartPos = self.Scroll
    anim.TargetPos = scrll
    anim.Think = function(an, pnl, fraction)
        pnl:SetScroll(Lerp(fraction, an.StartPos, an.TargetPos))
    end
end

--- Returns current scroll value.
---@return number scroll Current scroll amount.
function PANEL:GetScroll()
    if not self.Enabled then self.Scroll = 0 end
    return self.Scroll
end

--- Returns canvas Y offset derived from scroll.
---@return number offset Negative scroll offset.
function PANEL:GetOffset()
    if not self.Enabled then return 0 end
    return self.Scroll * -1
end

function PANEL:Think() end

function PANEL:OnMousePressed()
    if select(2, self:CursorPos()) > self.Scrollbar.y then
        self:SetScroll(self:GetScroll() + self.BarSize)
    else
        self:SetScroll(self:GetScroll() - self.BarSize)
    end
end

function PANEL:OnMouseReleased()
    self.Dragging = false
    self.DraggingCanvas = nil
    self:MouseCapture(false)

    self.Scrollbar.Depressed = false
end

--- Updates scroll while dragging the grip.
---@param x number Cursor X position.
---@param y number Cursor Y position.
function PANEL:OnCursorMoved(x, y)
    if not self.Enabled or not self.Dragging then return end

    y = select(2, self:ScreenToLocal(0, gui.MouseY())) - self.HoldPos

    local trackSize = self:GetTall() - self.Scrollbar:GetTall()
    y = y / trackSize

    self:SetScroll(math.Clamp(y * self.CanvasSize, 0, self.CanvasSize))
end

--- Starts grip dragging.
function PANEL:Grip()
    if not self.Enabled or self.BarSize == 0 then return end

    self:MouseCapture(true)
    self.Dragging = true

    self.HoldPos = select(2, self.Scrollbar:ScreenToLocal(x, gui.MouseY()))

    self.Scrollbar.Depressed = true
end

function PANEL:PerformLayout(w, h)
    self:LimitScroll()

    local scroll = self:GetScroll() / self.CanvasSize
    local barSize = math.max(self:BarScale() * self:GetTall(), 10)
    local track = self:GetTall() - barSize
    track = track + 1

    scroll = scroll * track

    local barStart = math.max(scroll, 0)
    local barEnd = math.min(scroll + barSize, self:GetTall())

    self.Scrollbar:SetPos(0, barStart)
    self.Scrollbar:SetSize(w, barEnd - barStart)
end

function PANEL:Paint(w, h)
    PIXEL.DrawRoundedBox(w / 2, 0, 0, w, h, self.BackgroundCol)
end

vgui.Register("PIXEL.Scrollbar", PANEL, "Panel")
