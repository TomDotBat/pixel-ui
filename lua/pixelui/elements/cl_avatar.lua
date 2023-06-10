
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

AccessorFunc(PANEL, "MaskSize", "MaskSize", FORCE_NUMBER)

function PANEL:Init()
    self.Avatar = vgui.Create("AvatarImage", self)
    self.Avatar:SetPaintedManually(true)

    self.CirclePoly = {}
    self:SetMaskSize(1)
end

function PANEL:PerformLayout(w, h)
    self.Avatar:SetSize(w, h)

    self.CirclePoly = {}
    local maskSize = self:GetMaskSize()

    local t = 0
    for i = 1, 360 do
        t = math.rad(i * 720) / 720
        self.CirclePoly[i] = {x = w / 2 + math.cos(t) * maskSize, y = h / 2 + math.sin(t) * maskSize}
    end
end

function PANEL:SetPlayer(ply, size)
    self.Avatar:SetPlayer(ply, size)
end

function PANEL:SetSteamID(id, size)
    self.Avatar:SetSteamID(id, size)
end

local render = render
local surface = surface
local whiteTexture = surface.GetTextureID("vgui/white")
function PANEL:Paint(w, h)
    render.ClearStencil()
    render.SetStencilEnable(true)

    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)

    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilReferenceValue(1)

    surface.SetTexture(whiteTexture)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawPoly(self.CirclePoly)

    render.SetStencilFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilReferenceValue(1)

    self.Avatar:SetPaintedManually(false)
    self.Avatar:PaintManual()
    self.Avatar:SetPaintedManually(true)

    render.SetStencilEnable(false)
    render.ClearStencil()
end

vgui.Register("PIXEL.Avatar", PANEL, "Panel")