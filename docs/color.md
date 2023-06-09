Found in `lua/pixelui/core/cl_color.lua`

# PIXEL.DecToHex

```lua
function PIXEL.DecToHex(dec, zeros)
```

Converts a decimal value to a hexadecimal string representation.

**Parameters:**
- `dec` (number) - The decimal value to convert.
- `zeros` (number, optional) - The number of leading zeros to add to the hexadecimal string. Defaults to 2.

**Returns:**
- `hex` (string) - The hexadecimal string representation of the decimal value.

---

# PIXEL.ColorToHex

```lua
function PIXEL.ColorToHex(color)
```

Converts a color to its hexadecimal string representation.

**Parameters:**
- `color` (Color) - The color to convert.

**Returns:**
- `hex` (string) - The hexadecimal string representation of the color.

---

# PIXEL.ColorToHSL

```lua
function PIXEL.ColorToHSL(color)
```

Converts a color to its HSL (Hue, Saturation, Lightness) representation.

**Parameters:**
- `color` (Color) - The color to convert.

**Returns:**
- `h` (number) - The hue value of the color.
- `s` (number) - The saturation value of the color.
- `l` (number) - The lightness value of the color.

---

# PIXEL.HSLToColor

```lua
function PIXEL.HSLToColor(h, s, l, a)
```

Converts HSL (Hue, Saturation, Lightness) values to a color.

**Parameters:**
- `h` (number) - The hue value.
- `s` (number) - The saturation value.
- `l` (number) - The lightness value.
- `a` (number, optional) - The alpha (opacity) value. Defaults to 1.

**Returns:**
- `color` (Color) - The color created from the HSL values.

---

# PIXEL.CopyColor

```lua
function PIXEL.CopyColor(color)
```

Creates a copy of a color.

**Parameters:**
- `color` (Color) - The color to copy.

**Returns:**
- `copiedColor` (Color) - A new color object with the same RGBA values as the original color.

---

# PIXEL.OffsetColor

```lua
function PIXEL.OffsetColor(color, offset)
```

Offsets the RGB values of a color by adding the specified offset.

**Parameters:**
- `color` (Color) - The color to offset.
- `offset` (number) - The offset value to add to each RGB component of the color.

**Returns:**
- `offsetColor` (Color) - A new color object with the offset RGB values.

---

# PIXEL.HexToColor

```lua
function PIXEL.HexToColor(hex)
```

Converts a hexadecimal string to a color.

**Parameters:**
- hex (string) - The hexadecimal string representation of a color.

**Returns:**
- color (Color) - The color created from the hexadecimal string.

---

# PIXEL.GetRainbowColor

```lua
function PIXEL.GetRainbowColor()
```

Returns a color that changes over time to create a rainbow effect.

---

# PIXEL.IsColorLight

```lua
function PIXEL.IsColorLight(color)
```

Checks if a color is considered light (greater than 0.5 lightness)

**Parameters:**
- `color` (Color) - The color to check.

**Returns:**
- `isLight` (boolean) - true if the color is considered light, false otherwise.

---

# PIXEL.LerpColor

```lua
function PIXEL.LerpColor(t, from, to)
```
Linearly interpolates between two colors.

**Parameters:**
- `t` (number) - The interpolation value between 0 and 1.
- `from` (Color) - The starting color.
- `to` (Color) - The ending color.

**Returns:**
- `lerpedColor` (Color) - The interpolated color between from and to.

---

# PIXEL.IsColorEqualTo

```lua
function PIXEL.IsColorEqualTo(from, to)
```
Checks if two colors are equal.

**Parameters:**
- `from` (Color) - The first color.
- `to` (Color) - The second color.

**Returns:**
- `isEqual` (boolean) - true if the colors are equal, false otherwise.

