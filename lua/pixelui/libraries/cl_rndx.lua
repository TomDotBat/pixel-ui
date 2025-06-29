--[[
Copyright (c) 2025 Srlion (https://github.com/Srlion)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

if SERVER then
	AddCSLuaFile()
	return
end

local bit_band = bit.band
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRectUV = surface.DrawTexturedRectUV
local surface_DrawTexturedRect = surface.DrawTexturedRect
local render_CopyRenderTargetToTexture = render.CopyRenderTargetToTexture
local math_min = math.min
local math_max = math.max
local DisableClipping = DisableClipping

local BLUR_RT = GetRenderTargetEx("DownsampledSceneRT" .. SysTime(),
	512, 512,
	RT_SIZE_LITERAL,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(2, 256, 4, 8 --[[4, 8 is clamp_s + clamp_t]]),
	0,
	IMAGE_FORMAT_BGRA8888
)

local SHADERS_VERSION = "1744632549"
local SHADERS_GMA = [========[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]========]
do
	local DECODED_SHADERS_GMA = util.Base64Decode(SHADERS_GMA)
	if not DECODED_SHADERS_GMA or #DECODED_SHADERS_GMA == 0 then
		print("Failed to load shaders!") -- this shouldn't happen
		return
	end

	file.Write("rndx_shaders_" .. SHADERS_VERSION .. ".gma", DECODED_SHADERS_GMA)
	game.MountGMA("data/rndx_shaders_" .. SHADERS_VERSION .. ".gma")
end

local function GET_SHADER(name)
	return SHADERS_VERSION:gsub("%.", "_") .. "_" .. name
end

-- I know it exists in gmod, but I want to have math.min and math.max localized
local function math_clamp(val, min, max)
	return (math_min(math_max(val, min), max))
end

local NEW_FLAG; do
	local flags_n = -1
	function NEW_FLAG()
		flags_n = flags_n + 1
		return 2 ^ flags_n
	end
end

local NO_TL, NO_TR, NO_BL, NO_BR           = NEW_FLAG(), NEW_FLAG(), NEW_FLAG(), NEW_FLAG()

-- Svetov/Jaffies's great idea!
local SHAPE_CIRCLE, SHAPE_FIGMA, SHAPE_IOS = NEW_FLAG(), NEW_FLAG(), NEW_FLAG()

local BLUR                                 = NEW_FLAG()

local RNDX                                 = {}

local shader_mat                           = [==[
screenspace_general
{
	$pixshader ""
	$vertexshader ""

	$basetexture ""
	$texture1    ""
	$texture2    ""
	$texture3    ""

	// Mandatory, don't touch
	$ignorez            1
	$vertexcolor        1
	$vertextransform    1
	"<dx90"
	{
		$no_draw 1
	}

	$copyalpha                 0
	$alpha_blend_color_overlay 0
	$alpha_blend               1 // for AA
	$linearwrite               1 // to disable broken gamma correction for colors
	$linearread_basetexture    1 // to disable broken gamma correction for textures
	$linearread_texture1       1 // to disable broken gamma correction for textures
	$linearread_texture2       1 // to disable broken gamma correction for textures
	$linearread_texture3       1 // to disable broken gamma correction for textures
}
]==]

local MATRIXES                             = {}

local function create_shader_mat(name, opts)
	assert(name and isstring(name), "create_shader_mat: name must be a string")

	local key_values = util.KeyValuesToTable(shader_mat, false, true)

	if opts then
		for k, v in pairs(opts) do
			key_values[k] = v
		end
	end

	local mat = CreateMaterial(
		"rndx_shaders1" .. name .. SysTime(),
		"screenspace_general",
		key_values
	)

	MATRIXES[mat] = Matrix()

	return mat
end

local ROUNDED_MAT = create_shader_mat("rounded", {
	["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
})
local ROUNDED_TEXTURE_MAT = create_shader_mat("rounded_texture", {
	["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = "loveyoumom", -- if there is no base texture, you can't change it later
})

local BLUR_VERTICAL = "$c0_x"
local ROUNDED_BLUR_MAT = create_shader_mat("blur_horizontal", {
	["$pixshader"] = GET_SHADER("rndx_rounded_blur_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = BLUR_RT:GetName(),
	["$texture1"] = "_rt_FullFrameFB",
})

local SHADOWS_MAT = create_shader_mat("rounded_shadows", {
	["$pixshader"] = GET_SHADER("rndx_shadows_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
})

local SHADOWS_BLUR_MAT = create_shader_mat("shadows_blur_horizontal", {
	["$pixshader"] = GET_SHADER("rndx_shadows_blur_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = "_rt_PowerOfTwoFB",
	["$texture1"] = "_rt_FullFrameFB",
})

local SHAPES = {
	[SHAPE_CIRCLE] = 2,
	[SHAPE_FIGMA] = 2.2,
	[SHAPE_IOS] = 4,
}

local MATERIAL_SetTexture = ROUNDED_MAT.SetTexture
local MATERIAL_SetMatrix = ROUNDED_MAT.SetMatrix
local MATERIAL_SetFloat = ROUNDED_MAT.SetFloat
local MATRIX_SetUnpacked = Matrix().SetUnpacked

local function SetParams(
	mat,
	tl, tr, bl, br,
	w, h,
	power,
	use_texture,
	outline_thickness,
	aa
)
	local matrix = MATRIXES[mat]
	MATRIX_SetUnpacked(
		matrix,

		bl, w, outline_thickness, 0,
		br, h, aa, 0,
		tr, power, 0, 0,
		tl, use_texture, 0, 0
	)
	MATERIAL_SetMatrix(mat, "$viewprojmat", matrix)
end

local MANUAL_COLOR = NEW_FLAG()
local DEFAULT_DRAW_FLAGS = SHAPE_FIGMA

local function draw_rounded(x, y, w, h, col, flags, tl, tr, bl, br, texture, thickness)
	if col and col.a == 0 then
		return
	end

	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end

	local using_blur = bit_band(flags, BLUR) ~= 0
	if using_blur then
		RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
		return
	end

	local mat = ROUNDED_MAT; if texture then
		mat = ROUNDED_TEXTURE_MAT
		MATERIAL_SetTexture(mat, "$basetexture", texture)
	end
	local max_rad = math_min(w, h) / 2
	local shape_value = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)]
	SetParams(
		mat,
		bit_band(flags, NO_TL) == 0 and math_clamp(tl, 0, max_rad) or 0,
		bit_band(flags, NO_TR) == 0 and math_clamp(tr, 0, max_rad) or 0,
		bit_band(flags, NO_BL) == 0 and math_clamp(bl, 0, max_rad) or 0,
		bit_band(flags, NO_BR) == 0 and math_clamp(br, 0, max_rad) or 0,
		w, h,
		shape_value or 2.2,
		texture and 1 or 0,
		thickness or -1,
		0
	)

	if bit_band(flags, MANUAL_COLOR) == 0 then
		if col then
			surface_SetDrawColor(col.r, col.g, col.b, col.a)
		else
			surface_SetDrawColor(255, 255, 255, 255)
		end
	end

	surface_SetMaterial(mat)
	-- https://github.com/Jaffies/rboxes/blob/main/rboxes.lua
	-- fixes setting $basetexture to ""(none) not working correctly
	surface_DrawTexturedRectUV(x, y, w, h, -0.015625, -0.015625, 1.015625, 1.015625)
end

function RNDX.Draw(r, x, y, w, h, col, flags)
	draw_rounded(x, y, w, h, col, flags, r, r, r, r)
end

function RNDX.DrawOutlined(r, x, y, w, h, col, thickness, flags)
	draw_rounded(x, y, w, h, col, flags, r, r, r, r, nil, thickness or 1)
end

function RNDX.DrawTexture(r, x, y, w, h, col, texture, flags)
	draw_rounded(x, y, w, h, col, flags, r, r, r, r, texture)
end

function RNDX.DrawMaterial(r, x, y, w, h, col, mat, flags)
	local tex = mat:GetTexture("$basetexture")
	if tex then
		RNDX.DrawTexture(r, x, y, w, h, col, tex, flags)
	end
end

function RNDX.DrawCircle(x, y, r, col, flags)
	RNDX.Draw(r / 2, x - r / 2, y - r / 2, r, r, col, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleOutlined(x, y, r, col, thickness, flags)
	RNDX.DrawOutlined(r / 2, x - r / 2, y - r / 2, r, r, col, thickness, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleTexture(x, y, r, col, texture, flags)
	RNDX.DrawTexture(r / 2, x - r / 2, y - r / 2, r, r, col, texture, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleMaterial(x, y, r, col, mat, flags)
	RNDX.DrawMaterial(r / 2, x - r / 2, y - r / 2, r, r, col, mat, (flags or 0) + SHAPE_CIRCLE)
end

local USE_SHADOWS_BLUR = false
local SHADOWS_AA = 0
function RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end

	local aa = 0
	local mat; if USE_SHADOWS_BLUR then
		mat = SHADOWS_BLUR_MAT
		aa = SHADOWS_AA
	else
		mat = ROUNDED_BLUR_MAT
	end

	local max_rad = math_min(w, h) / 2
	local shape_value = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)]
	SetParams(
		mat,
		bit_band(flags, NO_TL) == 0 and math_clamp(tl, 0, max_rad) or 0,
		bit_band(flags, NO_TR) == 0 and math_clamp(tr, 0, max_rad) or 0,
		bit_band(flags, NO_BL) == 0 and math_clamp(bl, 0, max_rad) or 0,
		bit_band(flags, NO_BR) == 0 and math_clamp(br, 0, max_rad) or 0,
		w, h,
		shape_value or 2.2,
		0,
		thickness or -1,
		aa
	)

	surface_SetDrawColor(255, 255, 255, 255)
	surface_SetMaterial(mat)

	render_CopyRenderTargetToTexture(BLUR_RT)
	MATERIAL_SetFloat(mat, BLUR_VERTICAL, 0)
	surface_DrawTexturedRect(x, y, w, h)

	render_CopyRenderTargetToTexture(BLUR_RT)
	MATERIAL_SetFloat(mat, BLUR_VERTICAL, 1)
	surface_DrawTexturedRect(x, y, w, h)
end

function RNDX.DrawShadowsEx(x, y, w, h, col, flags, tl, tr, bl, br, spread, intensity, thickness)
	if col and col.a == 0 then
		return
	end

	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end

	local using_blur = bit_band(flags, BLUR) ~= 0

	-- Shadows are a bit bigger than the actual box
	spread = spread or 30
	intensity = intensity or spread * 1.2

	x = x - spread
	y = y - spread
	w = w + (spread * 2)
	h = h + (spread * 2)

	tl = tl + (spread * 2)
	tr = tr + (spread * 2)
	bl = bl + (spread * 2)
	br = br + (spread * 2)
	--

	local mat = SHADOWS_MAT
	local max_rad = math_min(w, h) / 2
	local shape_value = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)]
	SetParams(
		mat,
		bit_band(flags, NO_TL) == 0 and math_clamp(tl, 0, max_rad) or 0,
		bit_band(flags, NO_TR) == 0 and math_clamp(tr, 0, max_rad) or 0,
		bit_band(flags, NO_BL) == 0 and math_clamp(bl, 0, max_rad) or 0,
		bit_band(flags, NO_BR) == 0 and math_clamp(br, 0, max_rad) or 0,
		w, h,
		shape_value or 2.2,
		0,
		thickness or -1,
		intensity
	)

	-- if we are inside a panel, we need to draw outside of it
	local old_clipping_state = DisableClipping(true)

	if using_blur then
		SHADOWS_AA = intensity
		USE_SHADOWS_BLUR = true
		RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
		USE_SHADOWS_BLUR = false
	end

	if bit_band(flags, MANUAL_COLOR) == 0 then
		if col then
			surface_SetDrawColor(col.r, col.g, col.b, col.a)
		else
			surface_SetDrawColor(0, 0, 0, 255)
		end
	end

	surface_SetMaterial(mat)
	-- https://github.com/Jaffies/rboxes/blob/main/rboxes.lua
	-- fixes having no $basetexture causing uv to be broken
	surface_DrawTexturedRectUV(x, y, w, h, -0.015625, -0.015625, 1.015625, 1.015625)

	DisableClipping(old_clipping_state)
end

function RNDX.DrawShadows(r, x, y, w, h, col, spread, intensity, flags)
	RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity)
end

-- Flags
RNDX.NO_TL = NO_TL
RNDX.NO_TR = NO_TR
RNDX.NO_BL = NO_BL
RNDX.NO_BR = NO_BR

RNDX.SHAPE_CIRCLE = SHAPE_CIRCLE
RNDX.SHAPE_FIGMA = SHAPE_FIGMA
RNDX.SHAPE_IOS = SHAPE_IOS

RNDX.BLUR = BLUR
RNDX.MANUAL_COLOR = MANUAL_COLOR

function RNDX.SetFlag(flags, flag, bool)
	flag = RNDX[flag] or flag
	if tobool(bool) then
		return bit.bor(flags, flag)
	else
		return bit.band(flags, bit.bnot(flag))
	end
end

PIXEL.RNDX = RNDX