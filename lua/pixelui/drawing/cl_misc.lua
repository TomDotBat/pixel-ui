
function PIXEL.DrawRoundedTextBox(text, font, x, y, xAlign, textCol, boxRounding, boxPadding, boxCol)
    local boxW, boxH = PIXEL.GetTextSize(text, font)

    local dblPadding = boxPadding * 2
    if xAlign == TEXT_ALIGN_CENTER then
        PIXEL.DrawRoundedBox(boxRounding, x - boxW / 2 - boxPadding, y - boxPadding, boxW + dblPadding, boxH + dblPadding, boxCol)
    elseif xAlign == TEXT_ALIGN_RIGHT then
        PIXEL.DrawRoundedBox(boxRounding, x - boxW - boxPadding, y - boxPadding, boxW + dblPadding, boxH + dblPadding, boxCol)
    else
        PIXEL.DrawRoundedBox(boxRounding, x - boxPadding, y - boxPadding, boxW + dblPadding, boxH + dblPadding, boxCol)
    end

    PIXEL.DrawText(text, font, x, y, textCol, xAlign)
end

function PIXEL.DrawFixedRoundedTextBox(text, font, x, y, xAlign, textCol, boxRounding, w, h, boxCol, textPadding)
    PIXEL.DrawRoundedBox(boxRounding, x, y, w, h, boxCol)

    if xAlign == TEXT_ALIGN_CENTER then
        PIXEL.DrawSimpleText(text, font, x + w / 2, y + h / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    if xAlign == TEXT_ALIGN_RIGHT then
        PIXEL.DrawSimpleText(text, font, x + w - textPadding, y + h / 2, textCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        return
    end

    PIXEL.DrawSimpleText(text, font, x + textPadding, y + h / 2, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local blurPassesCvar = CreateClientConVar("pixel_blurpasses", "4", true, false, "Amount of passes to draw blur with. 0 to disable blur entirely.", 0, 15)
local blurPassesNum = blurPassesCvar:GetInt()

cvars.AddChangeCallback("pixel_blurpasses", function(_, _, passes)
    blurPassesNum = math.floor(tonumber(passes) + 0.05)
end )

local blurMat = Material("pp/blurscreen")
local scrW, scrH = ScrW, ScrH
function PIXEL.DrawBlur(panel, localX, localY, w, h)
    local x, y = panel:LocalToScreen(localX, localY)
    local scrw, scrh = scrW(), scrH()

    surface.SetMaterial(blurMat)
    surface.SetDrawColor(255, 255, 255)

    if blurPassesNum ~= 0 then
        for i = 0, blurPassesNum do
            blurMat:SetFloat("$blur", i * .33)
            blurMat:Recompute()
        end
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrw, scrh)
    end
end
end