--[[
	PIXEL UI - Copyright Notice
	© 2023 Thomas O'Sullivan - All rights reserved

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local ceil = math.ceil
local setFont = PIXEL.SetFont
local getTextSize = PIXEL.GetTextSize
local setTextPos = surface.SetTextPos
local setTextColor = surface.SetTextColor
local drawText = surface.DrawText

--- Draws text and returns the measured width and height.
---@param text string Text to draw.
---@param font string PIXEL alias or raw font name.
---@param x number X position.
---@param y number Y position.
---@param col Color Text color.
---@param xAlign number|nil Horizontal alignment (TEXT_ALIGN_*).
---@param yAlign number|nil Vertical alignment (TEXT_ALIGN_*).
---@return number width Width of the drawn text.
---@return number height Height of the drawn text.
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

--- Draws text with newline and tab handling.
---@param text string Text to draw.
---@param font string PIXEL alias or raw font name.
---@param x number X position.
---@param y number Y position.
---@param col Color Text color.
---@param xAlign number|nil Horizontal alignment (TEXT_ALIGN_*).
---@param yAlign number|nil Vertical alignment (TEXT_ALIGN_*).
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

--- Draws shadowed text with a configurable depth.
---@param text string Text to draw.
---@param font string PIXEL alias or raw font name.
---@param x number X position.
---@param y number Y position.
---@param col Color Text color.
---@param xAlign number|nil Horizontal alignment (TEXT_ALIGN_*).
---@param yAlign number|nil Vertical alignment (TEXT_ALIGN_*).
---@param depth number Number of shadow passes.
---@param shadow number|nil Shadow alpha multiplier.
function PIXEL.DrawShadowText(text, font, x, y, col, xAlign, yAlign, depth, shadow)
    shadow = shadow or 50

    for i = 1, depth do
        drawSimpleText(text, font, x + i, y + i, Color(0, 0, 0, i * shadow), xAlign, yAlign)
    end

    drawSimpleText(text, font, x, y, col, xAlign, yAlign)
end

local drawShadowText = PIXEL.DrawShadowText

--- Draws a title/subtitle pair using shadowed text.
---@param title table Title tuple (text, font, color, align, depth, shadow).
---@param subtitle table Subtitle tuple (text, font, color, align, depth, shadow).
---@param x number|nil X position (defaults to 0).
---@param y number|nil Y position (defaults to 0).
---@param h number|nil Total height override.
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

--- Wraps text to a width using the provided font.
---@param text string Text to wrap.
---@param width number Maximum width in pixels.
---@param font string PIXEL alias or raw font name.
---@return string wrapped Wrapped text string.
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

--- Truncates text to a width, appending an ellipsis.
---@param text string Text to truncate.
---@param width number Maximum width in pixels.
---@param font string PIXEL alias or raw font name.
---@return string truncated Truncated text with ellipsis.
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
