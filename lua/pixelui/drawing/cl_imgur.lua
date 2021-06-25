
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

local drawProgressWheel
local setMaterial = surface.SetMaterial
local setDrawColor = surface.SetDrawColor

do
    local min = math.min
    local curTime = CurTime
    local drawTexturedRectRotated = surface.DrawTexturedRectRotated

    --Draws a progress wheel that rotates at the center point of the width/height arguments.
    --@tparam number the x position to start drawing from
    --@tparam number the y position to start drawing from
    --@tparam number the width of the progress wheel
    --@tparam number the height of the progress wheel
    --@tparam Color the Color of the progress wheel
    function PIXEL.DrawProgressWheel(x, y, w, h, col)
        local progSize = min(w, h)
        setMaterial(progressMat)
        setDrawColor(col.r, col.g, col.b, col.a)
        drawTexturedRectRotated(x + w * .5, y + h * .5, progSize, progSize, -curTime() * 100)
    end
    drawProgressWheel = PIXEL.DrawProgressWheel
end

local materials = {}
local grabbingMaterials = {}

local getImgur = PIXEL.GetImgur
getImgur(PIXEL.ProgressImageID, function(mat)
    progressMat = mat
end)

local drawTexturedRect = surface.DrawTexturedRect

--Draws an image from Imgur, chosen by the Imgur ID parameter. This will display a loading wheel in place of the image when downloading.
--@tparam number the x position to start drawing from
--@tparam number the y position to start drawing from
--@tparam number the width of the image
--@tparam number the height of the image
--@tparam string the Imgur ID of the image to download and draw
--@tparam Color the Color of the image
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

local drawTexturedRectRotated = surface.DrawTexturedRectRotated

--Draws an image from Imgur which can be rotated.
--@tparam number the x position to start drawing from
--@tparam number the y position to start drawing from
--@tparam number the width of the image
--@tparam number the height of the image
--@tparam number the rotation of the image
--@tparam string the Imgur ID of the image to download and draw
--@tparam Color the Color of the image
--@see PIXEL.DrawImgur
function PIXEL.DrawImgurRotated(x, y, w, h, rot, imgurId, col)
    if not materials[imgurId] then
        drawProgressWheel(x - w * .5, y - h * .5, w, h, col)

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
