
PIXEL.RegisterFontUnscaled("Overhead", "Open Sans Bold", 100)

local localPly
local function checkDistance(ent)
    if not IsValid(localPly) then localPly = LocalPlayer() end
    if localPly:GetPos():DistToSqr(ent:GetPos()) > 200000 then return true end
end

local function drawOverhead(ent, pos, text, ang, scale)
    if ang then
        ang = ent:LocalToWorldAngles(ang)
    else
        ang = (pos - localPly:GetPos()):Angle()
        ang:SetUnpacked(0, ang[2] - 90, 90)
    end

    surface.SetFont("PIXEL.Overhead")
    local w, h = surface.GetTextSize(text)
    w = w + 40
    h = h + 6

    local x, y = -(w * .5), -h

    local oldClipping = DisableClipping(true)

    cam.Start3D2D(pos, ang, scale or 0.05)
        PIXEL.DrawRoundedBox(12, x, y, w, h, PIXEL.Colors.Primary)
        PIXEL.DrawText(text, "PIXEL.Overhead", 0, y + 1, PIXEL.Colors.PrimaryText, TEXT_ALIGN_CENTER)
    cam.End3D2D()

    DisableClipping(oldClipping)
end

local entOffset = 2
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
