
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

--[[
    Should we override the default derma popups for the PIXEL UI reskins?
    0 = No - forced off.
    1 = No - but users can opt in via convar (pixel_ui_override_popups).
    2 = Yes - but users must opt in via convar.
    3 = Yes - forced on.
]]
PIXEL.OverrideDermaMenus = 0

--[[
    The Imgur ID of the progress image you want to appear when Imgur content is loading.
]]
PIXEL.ProgressImageID = "635PPvg"

--[[
    Colour definitions.
]]
PIXEL.Colors = {
    Background = Color(22, 22, 22),
    Header = Color(28, 28, 28),
    Scroller = Color(61, 61, 61),

    PrimaryText = Color(255, 255, 255),
    SecondaryText = Color(220, 220, 220),
    DisabledText = Color(40, 40, 40),

    Primary = Color(47, 128, 200),
    Disabled = Color(180, 180, 180),
    Positive = Color(66, 134, 50),
    Negative = Color(164, 50, 50),

    Gold = Color(214, 174, 34),
    Silver = Color(192, 192, 192),
    Bronze = Color(145, 94, 49),

    Transparent = Color(0, 0, 0, 0)
}