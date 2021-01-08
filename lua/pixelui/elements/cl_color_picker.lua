
local PANEL = {}

local gradientMat = Material("nil")
PIXEL.GetImgur("i0xcO1R", function(mat)
    gradientMat = mat
end)

local colorWheelMat = Material("nil")
PIXEL.GetImgur("k5mtok6", function(mat)
    colorWheelMat = mat
end)

local pickerMat = Material("nil")
PIXEL.GetImgur("t0k86qy", function(mat)
    pickerMat = mat
end)

function PANEL:Init()
    self.Hue = 0
    self.SmoothHue = 0

    self.Lightness = 0
    self.Saturation = 0

    self.TriX = 0
    self.TriY = 0

    self:UpdateColor()
    self:UpdatePositions()
end

function PANEL:OnChange(color) end

function PANEL:UpdateColor()
    self.Color = PIXEL.HSLToColor(self.Hue, self.Saturation, self.Lightness)
    self:OnChange(self.Color)
end

function PANEL:SetColor(color)
    local h, s, l = ColorToHSL(color)
    h = h / (360 / 5)
    self.Hue = h
    self.Saturation = s
    self.Lightness = l

    self.Color = color
    self:OnChange(color)

    self:UpdatePositions()
end

function PANEL:UpdatePositions()
    local hue = self.Hue
    local third = (2 / 3) * math.pi
    local sat = self.Saturation
    local light = 1 - self.Lightness

    local hX = math.cos(hue)
    local hY = math.sin(hue)
    local sX = math.cos(hue - third)
    local sY = math.sin(hue - third)
    local vX = math.cos(hue + third)
    local vY = math.sin(hue + third)

    local mX = (sX + vX) / 2
    local mY = (sY + vY) / 2
    local a = (1 - 2 * math.abs(light - 0.5)) * sat

    self.TriX = sX + (vX - sX) * light + (hX - mX) * a
    self.TriY = sY + (vY - sY) * light + (hY - mY) * a
end

function PANEL:Think()
    local cursorX, cursorY = self:CursorPos()
    local cX, cY = self:GetCenter()
    local triangleRadius = self:GetTriangleRadius()

    if not self.Pressed then return end

    local diffX = cursorX - cX
    local diffY = cursorY - cY
    local rad = math.atan2(diffY, diffX)

    if rad < 0 then
        rad = rad + (2 * math.pi)
    end

    if self.PressedWheel then
        self.Hue = rad
        self:UpdatePositions()
        self:UpdateColor()
        return
    end

    local rad0 = (rad + 2 * math.pi - self.Hue) % (2 * math.pi)
    local rad1 = rad0 % ((2 / 3) * math.pi) - (math.pi / 3)
    local a = 0.5 * triangleRadius
    local b = math.tan(rad1) * a
    local r = math.sqrt(diffX * diffX + diffY * diffY)
    local maxR = math.sqrt(a * a + b * b)

    if r > maxR then
        local dx = math.tan(rad1) * r
        local rad2 = math.Clamp(math.atan(dx / maxR), -math.pi / 3, math.pi / 3)
        rad = rad + (rad2 - rad1)
        rad0 = (rad + 2 * math.pi - self.Hue) % (2 * math.pi)
        rad1 = rad0 % ((2 / 3) * math.pi) - (math.pi / 3)
        b = math.tan(rad1) * a
        maxR = math.sqrt(a * a + b * b)
        r = maxR
    end

    self.TriX = math.cos(rad) * r / triangleRadius
    self.TriY = math.sin(rad) * r / triangleRadius

    local triangleSideLen = math.sqrt(3) * triangleRadius
    local light = ((math.sin(rad0) * r) / triangleSideLen) + 0.5
    local widthShare = 1.0 - math.abs(light - 0.5) * 2.0
    local saturation = (((math.cos(rad0) * r) + (triangleRadius / 2)) / (1.5 * triangleRadius)) / widthShare
    saturation = math.Clamp(saturation, 0, 1)

    self.Lightness = 1 - light
    self.Saturation = saturation

    self:UpdateColor()
end

function PANEL:OnMousePressed()
    self.Pressed = true

    local cX, cY = self:GetCenter()
    local cursorX, cursorY = self:CursorPos()
    local cursor = Vector(cursorX, cursorY)
    local center = Vector(cX, cY, 0)

    if cursor:Distance(center) > self:GetTriangleRadius() then
        self.PressedWheel = true
        return
    end

    self.PressedTriangle = true
end

function PANEL:OnMouseReleased()
    self.Pressed = false
    self.PressedWheel = false
    self.PressedTriangle = false
end

function PANEL:GetCenter()
    return self:GetWide() / 2, self:GetTall() / 2
end

function PANEL:GetRadius()
    return self:GetTall() / 2
end

function PANEL:GetTriangleRadius()
    return self:GetRadius() * 0.7
end

function PANEL:GetRingThickness()
    return self:GetRadius() * 0.2
end

function PANEL:GetHueColor()
    return PIXEL.HSLToColor(self.Hue, 1, 0.5)
end

local whiteTexture = surface.GetTextureID("vgui/white")
function PANEL:Paint(w, h)
    local cX, cY = self:GetCenter()
    local radius = self:GetRadius()
    local triangleRadius = self:GetTriangleRadius()

    surface.SetTexture(whiteTexture)

    local triangleAng = self.Hue
    local triangleOff = math.pi * 2 / 3
    local vertices = {
        {
            x = cX + math.cos(triangleAng - triangleOff) * triangleRadius,
            y = cY + math.sin(triangleAng - triangleOff) * triangleRadius,
            u = 0.5,
            v = 0.99
        },
        {
            x = cX + math.cos(triangleAng) * triangleRadius,
            y = cY + math.sin(triangleAng) * triangleRadius,
            u = 0.99,
            v = 0.01
        },
        {
            x = cX + math.cos(triangleAng + triangleOff * 1) * triangleRadius,
            y = cY + math.sin(triangleAng + triangleOff * 1) * triangleRadius,
            u = 0.01,
            v = 0.01
        }
    }

    local col = self:GetHueColor()
    surface.SetDrawColor(col)
    surface.DrawPoly(vertices)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(gradientMat)
    surface.DrawPoly(vertices)
    surface.DrawPoly(vertices)

    vertices[1].u = 0.99
    vertices[1].v = 0.01

    vertices[2].u = 0.01
    vertices[2].v = 0.01

    vertices[3].u = 0.5
    vertices[3].v = 0.99

    surface.SetDrawColor(0, 0, 0, 255)
    surface.SetMaterial(gradientMat)
    surface.DrawPoly(vertices)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(colorWheelMat)
    surface.DrawTexturedRect(cX - radius, cY - radius, radius * 2, radius * 2)

    local pickerVerts = {
        {
            x = cX + self.TriX * triangleRadius + 2,
            y = cY + self.TriY * triangleRadius + 2,
            u = 1,
            v = 1
        },
        {
            x = cX + self.TriX * triangleRadius - 2,
            y = cY + self.TriY * triangleRadius + 2,
            u = 0,
            v = 1
        },
        {
            x = cX + self.TriX * triangleRadius - 2,
            y = cY + self.TriY * triangleRadius - 2,
            u = 0,
            v = 0
        },
        {
            x = cX + self.TriX * triangleRadius + 2,
            y = cY + self.TriY * triangleRadius - 2,
            u = 1,
            v = 0
        }
    }

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(pickerMat)
    surface.DrawPoly(pickerVerts)

    local hpX = cX + math.cos(self.Hue) * (radius - self:GetRingThickness() / 2)
    local hpY = cY + math.sin(self.Hue) * (radius - self:GetRingThickness() / 2)
    local size = 16
    local huePickerVerts = {
        {
            x = hpX + size / 2,
            y = hpY + size / 2,
            u = 1,
            v = 1
        },
        {
            x = hpX - size / 2,
            y = hpY + size / 2,
            u = 0,
            v = 1
        },
        {
            x = hpX - size / 2,
            y = hpY - size / 2,
            u = 0,
            v = 0
        },
        {
            x = hpX + size / 2,
            y = hpY - size / 2,
            u = 1,
            v = 0
        }
    }
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(pickerMat)
    surface.DrawPoly(huePickerVerts)
end

vgui.Register("PIXEL.ColorPicker", PANEL, "Panel")