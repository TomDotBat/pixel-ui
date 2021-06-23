
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

local progressMat
local getImgur = PIXEL.GetImgur
getImgur(PIXEL.ProgressImageID, function(mat) progressMat = mat end)

local curTime = CurTime
local setMaterial = surface.SetMaterial
local setDrawColor = surface.SetDrawColor
local drawTexturedRectRotated = surface.DrawTexturedRectRotated
local drawTexturedRect = surface.DrawTexturedRect

local min = math.min
local function drawProgressWheel(x, y, w, h, col)
    local progSize = min(w, h)
    setMaterial(progressMat)
    setDrawColor(col.r, col.g, col.b, col.a)
    drawTexturedRectRotated(x + w / 2, y + h / 2, progSize, progSize, -curTime() * 100)
end
PIXEL.DrawProgressWheel = drawProgressWheel

local materials = {}
local grabbingMaterials = {}

function PIXEL.DrawImgur(x, y, w, h, imgurId, col)
    if not materials[imgurId] then
        drawProgressWheel(x, y, w, h, col)

        if grabbingMaterials[imgurId] then return end
        grabbingMaterials[imgurId] = true

        getImgur(imgurId, function(mat)
            materials[imgurId] = mat
            grabbingMaterials[imgurId] = nil
        end)

        return
    end

    setMaterial(materials[imgurId])
    setDrawColor(col.r, col.g, col.b, col.a)
    drawTexturedRect(x, y, w, h)
end

function PIXEL.DrawImgurRotated(x, y, w, h, rot, imgurId, col)
    if not materials[imgurId] then
        drawProgressWheel(x - w / 2, y - h / 2, w, h, col)

        if grabbingMaterials[imgurId] then return end
        grabbingMaterials[imgurId] = true

        getImgur(imgurId, function(mat)
            materials[imgurId] = mat
            grabbingMaterials[imgurId] = nil
        end)

        return
    end

    setMaterial(materials[imgurId])
    setDrawColor(col.r, col.g, col.b, col.a)
    drawTexturedRectRotated(x, y, w, h, rot)
end
