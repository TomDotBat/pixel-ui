
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

PIXEL.RegisterFontUnscaled("UI.Overhead", "Open Sans Bold", 100)

local localPly
local function checkDistance(ent)
    if not IsValid(localPly) then localPly = LocalPlayer() end
    if localPly:GetPos():DistToSqr(ent:GetPos()) > 200000 then return true end
end

local disableClipping = DisableClipping
local start3d2d, end3d2d = cam.Start3D2D, cam.End3D2D
local Icon = icon

local function drawOverhead(ent, pos, text, ang, scale)
    if ang then
        ang = ent:LocalToWorldAngles(ang)
    else
        ang = (pos - localPly:GetPos()):Angle()
        ang:SetUnpacked(0, ang[2] - 90, 90)
    end

    PIXEL.SetFont("UI.Overhead")
    local w, h = PIXEL.GetTextSize(text)
    w = w + 40
    h = h + 6

    local x, y = -(w * .5), -h

    local oldClipping = disableClipping(true)

    start3d2d(pos, ang, scale or 0.05)
    if not Icon then
        PIXEL.DrawRoundedBox(12, x, y, w, h, PIXEL.Colors.Primary)
        PIXEL.DrawText(text, "UI.Overhead", 0, y + 1, PIXEL.Colors.PrimaryText, TEXT_ALIGN_CENTER)
    else
        x = x - 40
        PIXEL.DrawRoundedBox(12, x, y, h, h, PIXEL.Colors.Primary)
        PIXEL.DrawRoundedBoxEx(12, x + (h - 12), y + h - 20, w + 15, 20, PIXEL.Colors.Primary, false, false, false, true)
        PIXEL.DrawText(text, "UI.Overhead", x + h + 15, y + 8, PIXEL.Colors.PrimaryText)
        PIXEL.DrawImgur(x + 10, y + 10, h - 20, h - 20, Icon, color_white)
    end
    end3d2d()

    disableClipping(oldClipping)
end

local entOffset = 2

--Draws an overhead above an entity.
--@tparam Entity the entity the overhead is being drawn above
--@tparam string the text to show on the overhead
--@tparam Angle[opt] an Angle to override instead of facing the player
--@tparam Vector[opt] a Vector to override the position instead determining the top of the Entity
--@tparam number[opt=0.05] a scale percentage decimal to override the default overhead scale
function PIXEL.DrawEntOverhead(ent, text, angleOverride, posOverride, scaleOverride)
    if checkDistance(ent) then return end

    if posOverride then
        drawOverhead(ent, ent:LocalToWorld(posOverride), text, angleOverride, scaleOverride)
        return
    end

    local pos = ent:OBBMaxs()
    pos:SetUnpacked(0, 0, pos[3] + entOffset)

    drawOverhead(ent, ent:LocalToWorld(pos), text, angleOverride, scaleOverride)
end

local eyeOffset = Vector(0, 0, 7)
local fallbackOffset = Vector(0, 0, 73)

--Draws an overhead above an NPC's head.
--@tparam Entity the entity the overhead is being drawn above
--@tparam string the text to show on the overhead
--@tparam Angle[opt] an Angle to override instead of facing the player
--@tparam Vector[opt] a Vector to override the default position offset
--@tparam number[opt=0.05] a scale percentage decimal to override the default overhead scale
function PIXEL.DrawNPCOverhead(ent, text, angleOverride, offsetOverride, scaleOverride)
    if checkDistance(ent) then return end

    local eyeId = ent:LookupAttachment("eyes")
    if eyeId then
        local eyes = ent:GetAttachment(eyeId)
        if eyes then
            eyes.Pos:Add(offsetOverride or eyeOffset)
            drawOverhead(ent, eyes.Pos, text, angleOverride, scaleOverride)
            return
        end
    end

    drawOverhead(ent, ent:GetPos() + fallbackOffset, text, angleOverride, scaleOverride)
end

--Enables the drawing of icon overheads and sets the icon ID to use.
--@tparam string the new icon ID to use on overheads
--@treturn string the last icon ID used
function PIXEL.EnableIconOverheads(new)
    local oldIcon = Icon
    Icon = new
    return oldIcon
end