
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

local ceil = math.ceil
local setFont = PIXEL.SetFont
local getTextSize = PIXEL.GetTextSize
local setTextPos = surface.SetTextPos
local setTextColor = surface.SetTextColor
local drawText = surface.DrawText

function PIXEL.DrawSimpleText(text, font, x, y, col, xAlign, yAlign)
    setFont(font)
    local w, h = getTextSize(text)

    if xAlign == 1 then
        x = x - w / 2
    elseif xAlign == 2 then
        x = x - w
    end

    if yAlign == 1 then
        y = y - h / 2
    elseif yAlign == 4 then
        y = y - h
    end

    setTextPos(ceil(x), ceil(y))
    setTextColor(col.r, col.g, col.b, col.a)
    drawText(text)

    return w, h
end

local drawSimpleText = PIXEL.DrawSimpleText
local gmatch = string.gmatch
local find = string.find
local max = math.max
local select = select

function PIXEL.DrawText(text, font, x, y, col, xAlign, yAlign)
    local curX = x
    local curY = y

    setFont(font)
    local lineHeight = select(2, getTextSize("\n"))
    local tabWidth = 50

    for str in gmatch(text, "[^\n]*") do
        if #str > 0 then
            if find(str, "\t") then
                for tabs, str2 in gmatch(str, "(\t*)([^\t]*)") do
                    curX = ceil((curX + tabWidth * max(#tabs - 1, 0 )) / tabWidth) * tabWidth

                    if #str2 > 0 then
                        drawSimpleText(str2, font, curX, curY, col, xAlign)
                        curX = curX + getTextSize(str2)
                    end
                end
            else
                drawSimpleText(str, font, curX, curY, col, xAlign)
            end
        else
            curX = x
            curY = curY + lineHeight / 2
        end
    end
end

function PIXEL.DrawShadowText(text, font, x, y, col, xAlign, yAlign, depth, shadow)
    shadow = shadow or 50

    for i = 1, depth do
        drawSimpleText(text, font, x + i, y + i, Color(0, 0, 0, i * shadow), xAlign, yAlign)
    end

    drawSimpleText(text, font, x, y, col, xAlign, yAlign)
end

local drawShadowText = PIXEL.DrawShadowText

function PIXEL.DrawDualText(title, subtitle, x, y, h)
    x = x or 0
    y = y or 0

    setFont(title[2])
    local tH = select(2, getTextSize(title[1]))

    setFont(subtitle[2])
    local sH = select(2, getTextSize(subtitle[1]))

    drawShadowText(title[1], title[2], x, y - sH / 2, title[3], title[4], 1, title[5], title[6])
    drawShadowText(subtitle[1], subtitle[2], x, y + tH / 2, subtitle[3], subtitle[4], 1, subtitle[5], subtitle[6])
end

local textWrapCache = {}

local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0

    text = text:gsub(".", function(char)
        totalWidth = totalWidth + getTextSize(char)

        if totalWidth >= remainingWidth then
            totalWidth = getTextSize(char)
            remainingWidth = maxWidth
            return "\n" .. char
        end

        return char
    end)

    return text, totalWidth
end

local subString = string.sub

function PIXEL.WrapText(text, width, font) --Edit of https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/cl_util.lua#L21
    local chachedName = text .. width .. font
    if textWrapCache[chachedName] then return textWrapCache[chachedName] end

    setFont(font)
    local textWidth = getTextSize(text)

    if textWidth <= width then
        textWrapCache[chachedName] = text
        return text
    end

    local totalWidth = 0
    local spaceWidth = getTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
        local char = subString(word, 1, 1)
        if char == "\n" or char == "\t" then
            totalWidth = 0
        end

        local wordlen = getTextSize(word)
        totalWidth = totalWidth + wordlen

        if wordlen >= width then
            local splitWord, splitPoint = charWrap(word, width - (totalWidth - wordlen), width)
            totalWidth = splitPoint
            return splitWord
        elseif totalWidth < width then
            return word
        end

        if char == ' ' then
            totalWidth = wordlen - spaceWidth
            return '\n' .. subString(word, 2)
        end

        totalWidth = wordlen
        return '\n' .. word
    end)

    textWrapCache[chachedName] = text
    return text
end

local left = string.Left

local ellipsesTextCache = {}

function PIXEL.EllipsesText(text, width, font)
    local chachedName = text .. width .. font
    if ellipsesTextCache[chachedName] then return ellipsesTextCache[chachedName] end

    setFont(font)
    local textWidth = getTextSize(text)

    if textWidth <= width then
        ellipsesTextCache[chachedName] = text
        return text
    end

    local infiniteLoopPrevention = 0 --Just in case we really fuck up

    repeat
        text = left(text, #text - 1)
        textWidth = getTextSize(text .. "...")

        infiniteLoopPrevention = infiniteLoopPrevention + 1
    until textWidth <= width or infiniteLoopPrevention > 10000

    text = text .. "..."

    ellipsesTextCache[chachedName] = text
    return text
end