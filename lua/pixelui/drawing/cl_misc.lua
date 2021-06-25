
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

--Draws a rounded box with text inside.
--@tparam string the text to draw
--@tparam string the font identifier of the font you want to draw the text with
--@tparam number the x position to start drawing from
--@tparam number the y position to start drawing from
--@tparam number[opt="TEXT_ALIGN_LEFT"] a TEXT_ALIGN_* enum to describe the text alignment
--@tparam Color the Color of the text
--@tparam number the rounding of the box
--@tparam number the padding around the text from the side of the box
--@tparam Color the Color of the box
--@see PIXEL.DrawFixedRoundedTextBox
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


--Draws a rounded box with text inside.
--@tparam string the text to draw
--@tparam string the font identifier of the font you want to draw the text with
--@tparam number the x position to start drawing from
--@tparam number the y position to start drawing from
--@tparam number[opt="TEXT_ALIGN_LEFT"] a TEXT_ALIGN_* enum to describe the text alignment
--@tparam Color the Color of the text
--@tparam number the rounding of the box
--@tparam number the width of the box
--@tparam number the height of the box
--@tparam Color the Color of the box
--@tparam number an amount of pixels to offset the text into the box on both axes
--@see PIXEL.DrawRoundedTextBox
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

local blurPassesCvar = CreateClientConVar("pixel_ui_blur_passes", "4", true, false, "Amount of passes to draw blur with. 0 to disable blur entirely.", 0, 15)
local blurPassesNum = blurPassesCvar:GetInt()

cvars.AddChangeCallback("pixel_ui_blur_passes", function(_, _, passes)
    blurPassesNum = math.floor(tonumber(passes) + 0.05)
end )

local blurMat = Material("pp/blurscreen")
local scrW, scrH = ScrW, ScrH

--Draws a blur texture in a specified location.
--@tparam Panel the panel the blur texture is being drawn on
--@tparam number the x position to start the blur from
--@tparam number the y position to start the blur from
--@tparam number the width of the blur
--@tparam number the height of the blur
function PIXEL.DrawBlur(panel, localX, localY, w, h)
    if blurPassesNum == 0 then return end
    local x, y = panel:LocalToScreen(localX, localY)
    local scrw, scrh = scrW(), scrH()

    surface.SetMaterial(blurMat)
    surface.SetDrawColor(255, 255, 255)

    for i = 0, blurPassesNum do
        blurMat:SetFloat("$blur", i * .33)
        blurMat:Recompute()
    end
    render.UpdateScreenEffectTexture()
    surface.DrawTexturedRect(x * -1, y * -1, scrw, scrh)
end
