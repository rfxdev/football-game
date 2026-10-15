class_name SheetDescription
extends Resource
## How to read one sheet, per Sheets in Sprites: a grid of equal cells, a row
## per facing and a column per frame, with the anchor at the same point in every
## cell. Every art source shares it — the sideloaded sheet is named and laid out
## as this says, not the other way round.

## The sideloaded sheet's name in [constant Sideload.SPRITES_DIR].
@export var file_name: String
@export var cell_size: Vector2i
## The point in every cell that is drawn at the sprite's position.
@export var anchor: Vector2i
@export var columns: int
@export var rows: int
## The columns each animation shows, in order. Which one shows, and when, is
## the match's to say.
@export var animations: Dictionary[StringName, PackedInt32Array]
## The committed sheet, laid out the same, drawn wherever the sideloaded one is
## missing or malformed.
@export var placeholder: Texture2D


func sheet_size() -> Vector2i:
	return cell_size * Vector2i(columns, rows)


func cell_rect(column: int, row: int) -> Rect2i:
	return Rect2i(cell_size * Vector2i(column, row), cell_size)
