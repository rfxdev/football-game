class_name Sideload
## Reads the art a player sideloads from their own copy of the reference, per
## Sideloaded Art in Sprites. It lives under user://, never res://, per Local
## Data. Each sheet and palette falls back on its own, so a partial set draws
## like a full one.

const SPRITES_DIR := "user://sideload/sprites"
const PALETTES_DIR := "user://sideload/palettes"

const _PNG_SIGNATURE := [137, 80, 78, 71, 13, 10, 26, 10]
# IHDR is always the first chunk, so its fields sit at fixed offsets.
const _IHDR_NAME := 12
const _IHDR_BIT_DEPTH := 24
const _IHDR_COLOUR_TYPE := 25
const _GREYSCALE := 0


## The sheet [param description] names in [param directory], or the
## description's placeholder if it's missing, isn't 8-bit greyscale, or isn't
## the size the description gives.
static func sheet(description: SheetDescription, directory: String) -> Texture2D:
	var image := read_sheet(description, directory)
	return ImageTexture.create_from_image(image) if image else description.placeholder


## The palette [param description] names in [param directory], or the
## project's own if it's missing or the wrong size.
static func palette(description: PaletteDescription, directory: String) -> Texture2D:
	var image := read_palette(description, directory)
	return ImageTexture.create_from_image(image) if image else description.fallback


## The sheet's image, one palette entry per pixel, or null if it can't be used.
static func read_sheet(description: SheetDescription, directory: String) -> Image:
	var bytes := _read(directory.path_join(description.file_name))
	if not is_8_bit_greyscale_png(bytes):
		return null
	var image := _decode(bytes, description.sheet_size())
	if image and image.get_format() != Image.FORMAT_L8:
		# A transparency chunk decodes with alpha; entry 0 is the transparency.
		image.convert(Image.FORMAT_L8)
	return image


## The palette's image, one colour per entry, or null if it can't be used.
static func read_palette(description: PaletteDescription, directory: String) -> Image:
	var image := _decode(
		_read(directory.path_join(description.file_name)), description.image_size()
	)
	if image:
		image.convert(Image.FORMAT_RGB8)
	return image


## Read from the header rather than the decoded image, which Godot expands
## from 16-bit or indexed without saying so.
static func is_8_bit_greyscale_png(bytes: PackedByteArray) -> bool:
	if bytes.size() <= _IHDR_COLOUR_TYPE:
		return false
	if Array(bytes.slice(0, _PNG_SIGNATURE.size())) != _PNG_SIGNATURE:
		return false
	if bytes.slice(_IHDR_NAME, _IHDR_NAME + 4).get_string_from_ascii() != "IHDR":
		return false
	return bytes[_IHDR_BIT_DEPTH] == 8 and bytes[_IHDR_COLOUR_TYPE] == _GREYSCALE


static func _read(path: String) -> PackedByteArray:
	if not FileAccess.file_exists(path):
		return PackedByteArray()
	return FileAccess.get_file_as_bytes(path)


static func _decode(bytes: PackedByteArray, size: Vector2i) -> Image:
	if bytes.is_empty():
		return null
	var image := Image.new()
	if image.load_png_from_buffer(bytes) != OK or image.get_size() != size:
		return null
	return image
