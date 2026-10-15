class_name PaletteDescription
extends Resource
## How to read one palette, per Sideloaded Art in Sprites: an image one pixel
## per entry, in entry order. The project's own has the same shape.

## The sideloaded palette's name in [constant Sideload.PALETTES_DIR].
@export var file_name: String
@export var entry_count: int
## The project's own palette, used wherever the sideloaded one is missing or the
## wrong size.
@export var fallback: Texture2D


func image_size() -> Vector2i:
	return Vector2i(entry_count, 1)
