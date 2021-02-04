
--https://gist.github.com/MysteryPancake/a31637af9fd531079236a2577145a754
--https://gitlab.com/louiethewaterfaller/blues-shadows/-/blob/master/lua/autorun/client/cl_bshadows.lua

local function load()
    local bShadows = {}

	local scrW, scrH = ScrW(), ScrW()
    local resStr = scrW .. "" .. scrH

    --The original drawing layer
    bShadows.RenderTarget = GetRenderTarget("bshadows_original_" .. resStr, scrW, scrH)
    
    --The matarial to draw the render targets on
    bShadows.ShadowMaterial = CreateMaterial("bshadows_" .. resStr, "UnlitGeneric", {
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["alpha"] = 1
    })

    bShadows.CreatedShadowMaterials = {}
    
    --Call this to begin drawing a shadow
    bShadows.BeginShadow = function(uniqueID, areaX, areaY, areaEndX, areaEndY)
        --Set the render target so all draw calls draw onto the render target instead of the screen
        render.PushRenderTarget(bShadows.RenderTarget)
    
        --Clear is so that theres no color or alpha
        render.OverrideAlphaWriteEnable(true, true)
        render.Clear(0, 0, 0, 0)
        render.OverrideAlphaWriteEnable(false, false)
    
        if (bShadows.CreatedShadowMaterials[uniqueID] and areaX and areaY and areaEndX and areaEndY) then
            render.SetScissorRect(areaX, areaY, areaEndX, areaEndY, true)

            if (not bShadows.CreatedShadowMaterials[uniqueID][4]) then
                bShadows.CreatedShadowMaterials[uniqueID][4] = areaX
                bShadows.CreatedShadowMaterials[uniqueID][5] = areaY
                bShadows.CreatedShadowMaterials[uniqueID][6] = areaEndX
                bShadows.CreatedShadowMaterials[uniqueID][7] = areaEndY
            end
        end

        --Start Cam2D as where drawing on a flat surface 
        cam.Start2D()
    
        --Now leave the rest to the user to draw onto the surface
    end
    
    --This will draw the shadow, and mirror any other draw calls the happened during drawing the shadow
    bShadows.EndShadow = function(uniqueID, x, y, intensity, spread, blur, opacity, direction, distance, _shadowOnly)
        -- Set default opcaity
        opacity = opacity or 255
        direction = direction or 0
        distance = distance or 0
        _shadowOnly = _shadowOnly or false
    
        if (not bShadows.CreatedShadowMaterials[uniqueID]) then
            local shadowRenderTarget = GetRenderTarget("bshadows_shadow_" .. resStr .. "_id_" .. uniqueID, scrW, scrH, scrH)
            -- Copy this render target to the other
            render.CopyRenderTargetToTexture(shadowRenderTarget)
        
            --Blur the second render target
            if blur > 0 then
                render.OverrideAlphaWriteEnable(true, true)
                render.BlurRenderTarget(shadowRenderTarget, spread, spread, blur)
                render.OverrideAlphaWriteEnable(false, false) 
            end

            bShadows.CreatedShadowMaterials[uniqueID] = {CreateMaterial("bshadows_grayscale_" .. resStr .. "_id_" .. uniqueID, "UnlitGeneric", {
                ["$translucent"] = 1,
                ["$vertexalpha"] = 1,
                ["$alpha"] = 1,
                ["$color"] = "0 0 0",
                ["$color2"] = "0 0 0"
            }), x, y}

            bShadows.CreatedShadowMaterials[uniqueID][1]:SetTexture("$basetexture", shadowRenderTarget)
            bShadows.CreatedShadowMaterials[uniqueID][1]:SetFloat("$alpha", opacity / 255)
        end

        --First remove the render target that the user drew
        render.PopRenderTarget()

        --Now update the material to what was drawn
        bShadows.ShadowMaterial:SetTexture("$basetexture", bShadows.RenderTarget)
        
        --Work out shadow offsets
        local shadowTable = bShadows.CreatedShadowMaterials[uniqueID]
        local xOffset = math.sin(math.rad(direction)) * distance 
        local yOffset = math.cos(math.rad(direction)) * distance

        if (shadowTable[4]) then 
            render.SetScissorRect(shadowTable[4], shadowTable[5] + 1, shadowTable[6], shadowTable[7] - 1, true)
        end

        render.SetMaterial(shadowTable[1])

        for i = 1 , math.ceil(intensity) do
            render.DrawScreenQuadEx(xOffset + (x - shadowTable[2]), yOffset + (y - shadowTable[3]), scrW, scrH)
        end

        if (shadowTable[4]) then render.SetScissorRect(0, 0, 0, 0, false) end
    
        if not _shadowOnly then
            --Now draw the original
            bShadows.ShadowMaterial:SetTexture("$basetexture", bShadows.RenderTarget)
            render.SetMaterial(bShadows.ShadowMaterial)
            render.DrawScreenQuad()
        end
    
        cam.End2D()

        render.SetScissorRect(0, 0, 0, 0, false)
    end
	
	PIXEL.BShadows = bShadows
end

hook.Add("OnScreenSizeChanged", "PIXEL.UI.BShadows.ResolutionChanged", load)
load()
