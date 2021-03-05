
local progressMat
local getImgur = PIXEL.GetImgur
getImgur("635PPvg", function(mat) progressMat = mat end)

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

do
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
end