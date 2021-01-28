
local progressMat = Material("error")
PIXEL.GetImgur("635PPvg", function(mat) progressMat = mat end)

function PIXEL.DrawProgressWheel(x, y, w, h, col)
    local progSize = math.min(w, h)
    surface.SetMaterial(progressMat)
    surface.SetDrawColor(col.r, col.g, col.b, col.a)
    surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, progSize, progSize, -CurTime() * 100)
end

local grabbingMaterials = {}
local materials = {}

function PIXEL.DrawImgur(x, y, w, h, imgurId, col)
    if not materials[imgurId] then
        PIXEL.DrawProgressWheel(x, y, w, h, col)

        if grabbingMaterials[imgurId] then return end
        grabbingMaterials[imgurId] = true

        PIXEL.GetImgur(imgurId, function(mat)
            materials[imgurId] = mat
            grabbingMaterials[imgurId] = nil
        end)

        return
    end

    surface.SetMaterial(materials[imgurId])
    surface.SetDrawColor(col.r, col.g, col.b, col.a)
    surface.DrawTexturedRect(x, y, w, h)
end

function PIXEL.DrawImgurRotated(x, y, w, h, rot, imgurId, col)
    if not materials[imgurId] then
        PIXEL.DrawProgressWheel(x - w / 2, y - h / 2, w, h, col)

        if grabbingMaterials[imgurId] then return end
        grabbingMaterials[imgurId] = true

        PIXEL.GetImgur(imgurId, function(mat)
            materials[imgurId] = mat
            grabbingMaterials[imgurId] = nil
        end)

        return
    end

    surface.SetMaterial(materials[imgurId])
    surface.SetDrawColor(col.r, col.g, col.b, col.a)
    surface.DrawTexturedRectRotated(x, y, w, h, rot)
end