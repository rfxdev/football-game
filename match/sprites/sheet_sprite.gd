class_name SheetSprite
extends Sprite2D
## One sprite drawn from its sheet, per Sheets in Sprites. Every cell lands with
## its anchor on the node's position. The match says which cell shows, so the
## sprite runs no animation clock of its own.

@export var description: SheetDescription


func _ready() -> void:
	if texture == null:
		show_sheet(MatchArt.sheet(description))
		material = MatchArt.palette_material()


## Draws from [param sheet], laid out as [member description] says.
func show_sheet(sheet: Texture2D) -> void:
	texture = sheet
	centered = false
	region_enabled = true
	offset = -Vector2(description.anchor)
	show_cell(0)


func show_cell(column: int, row: int = 0) -> void:
	region_rect = Rect2(description.cell_rect(column, row))


## Draws the anchor at [param at], in world units, on the nearest whole screen
## pixel. Every world pixel then covers the same whole number of screen pixels,
## per Pixels, while the sprite still moves a screen pixel at a time rather
## than a world pixel.
func place(at: Vector2) -> void:
	var pixels_per_unit := get_viewport().get_final_transform().get_scale()
	global_position = (at * pixels_per_unit).round() / pixels_per_unit
