class_name MatchArt
## The match's art, read once on first use and shared: each sheet, sideloaded
## or its placeholder, and the palette material every sprite draws through.
## Tests never come through here — they hand [Sideload] a directory of their
## own, per Local Data.

const MATCH_PALETTE: PaletteDescription = preload("res://art/palettes/match.tres")
const PALETTE_SHADER: Shader = preload("res://match/sprites/palette.gdshader")

static var _sheets: Dictionary[SheetDescription, Texture2D] = {}
static var _material: ShaderMaterial


static func sheet(description: SheetDescription) -> Texture2D:
	if not _sheets.has(description):
		_sheets[description] = Sideload.sheet(description, Sideload.SPRITES_DIR)
	return _sheets[description]


## The ball has no kit, so the match palette's fixed entries are all it needs.
static func palette_material() -> ShaderMaterial:
	if _material == null:
		_material = ShaderMaterial.new()
		_material.shader = PALETTE_SHADER
		var palette := Sideload.palette(MATCH_PALETTE, Sideload.PALETTES_DIR)
		_material.set_shader_parameter(&"palette", palette)
	return _material
