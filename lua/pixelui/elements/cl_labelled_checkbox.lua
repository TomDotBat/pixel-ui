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

function PANEL:Init()
    self.Checkbox = vgui.Create("PIXEL.Checkbox", self)

    self.Checkbox.OnToggled = function(s, enabled)
        self:OnToggled(enabled)
    end

    self.LabelHolder = vgui.Create("Panel", self)
    self.Label = vgui.Create("PIXEL.Label", self.LabelHolder)
    self.Label:SetAutoWidth(true)
    self.Label:SetAutoHeight(true)

    self.LabelHolder.PerformLayout = function(s, w, h)
        self.Label:CenterVertical()
        s:SizeToChildren(true, true)
        self:SizeToChildren(true, true)
    end
end

function PANEL:PerformLayout(w, h)
    self.Checkbox:Dock(LEFT)
    self.Checkbox:SetWide(h)
    self.Checkbox:DockMargin(0, 0, PIXEL.Scale(6), 0)

    self.LabelHolder:Dock(LEFT)
end

function PANEL:OnToggled(enabled) end

function PANEL:SetText(text) self.Label:SetText(text) end
function PANEL:GetText() return self.Label:GetText() end

function PANEL:SetFont(font) self.Label:SetFont(font) end
function PANEL:GetFont() return self.Label:GetFont() end

function PANEL:SetTextColor(col) self.Label:SetTextColor(col) end
function PANEL:GetTextColor() return self.Label:GetTextColor() end

function PANEL:SetAutoWrap(enabled) self.Label:SetAutoWrap(enabled) end
function PANEL:GetAutoWrap() return self.Label:GetAutoWrap() end

vgui.Register("PIXEL.LabelledCheckbox", PANEL, "Panel")