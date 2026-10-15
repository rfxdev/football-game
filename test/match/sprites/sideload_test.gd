extends GdUnitTestSuite
## Sideloaded Art in Sprites: a sideloaded sheet draws exactly where its
## placeholder would, and a malformed sheet or palette is passed over for the
## project's own. Synthetic fixtures in a temporary directory, never the
## player's user://sideload, per Local Data.

const BALL := preload("res://art/sprites/ball.tres")
const MATCH_PALETTE := preload("res://art/palettes/match.tres")
## Where a PNG's header gives its bit depth.
const BIT_DEPTH_BYTE := 24


func test_a_missing_sheet_draws_the_placeholder() -> void:
	var directory := create_temp_dir("sideload/missing_sheet")
	assert_object(Sideload.sheet(BALL, directory)).is_same(BALL.placeholder)


func test_a_well_formed_sheet_is_read_as_it_is() -> void:
	var directory := create_temp_dir("sideload/well_formed_sheet")
	var image := _grey_image(BALL.sheet_size())
	image.save_png(directory.path_join(BALL.file_name))
	assert_object(Sideload.sheet(BALL, directory)).is_not_same(BALL.placeholder)
	assert_array(Sideload.read_sheet(BALL, directory).get_data()).is_equal(image.get_data())


func test_a_sideloaded_sheet_draws_at_its_placeholders_position_size_and_layer() -> void:
	var directory := create_temp_dir("sideload/sheet_draws")
	_grey_image(BALL.sheet_size()).save_png(directory.path_join(BALL.file_name))
	var placeholder := _sprite(BALL.placeholder)
	var sideloaded := _sprite(Sideload.sheet(BALL, directory))
	assert_object(sideloaded.texture).is_not_same(placeholder.texture)
	assert_vector(sideloaded.position).is_equal(placeholder.position)
	assert_int(sideloaded.z_index).is_equal(placeholder.z_index)
	for column in BALL.columns:
		placeholder.show_cell(column)
		sideloaded.show_cell(column)
		assert_that(sideloaded.get_rect()).is_equal(placeholder.get_rect())
		assert_that(sideloaded.region_rect).is_equal(placeholder.region_rect)


func test_a_sheet_of_the_wrong_size_draws_the_placeholder(
	size: Vector2i,
	_test_parameters := [
		[Vector2i(15, 4)], [Vector2i(17, 4)], [Vector2i(16, 3)], [Vector2i(16, 8)], [Vector2i(4, 4)]
	]
) -> void:
	var directory := create_temp_dir("sideload/wrong_size_%d_%d" % [size.x, size.y])
	_grey_image(size).save_png(directory.path_join(BALL.file_name))
	assert_object(Sideload.sheet(BALL, directory)).is_same(BALL.placeholder)


func test_a_sheet_not_in_greyscale_draws_the_placeholder(
	format: int, _test_parameters := [[Image.FORMAT_RGB8], [Image.FORMAT_RGBA8], [Image.FORMAT_LA8]]
) -> void:
	var directory := create_temp_dir("sideload/format_%d" % format)
	var image := _grey_image(BALL.sheet_size())
	image.convert(format)
	image.save_png(directory.path_join(BALL.file_name))
	assert_object(Sideload.sheet(BALL, directory)).is_same(BALL.placeholder)


## Godot can't write a 16-bit PNG, so the fixture's header claims one.
func test_a_sheet_in_16_bit_greyscale_draws_the_placeholder() -> void:
	var directory := create_temp_dir("sideload/sixteen_bit")
	var bytes := _grey_image(BALL.sheet_size()).save_png_to_buffer()
	bytes[BIT_DEPTH_BYTE] = 16
	_store(bytes, directory.path_join(BALL.file_name))
	assert_object(Sideload.sheet(BALL, directory)).is_same(BALL.placeholder)


func test_a_sheet_that_is_not_a_png_draws_the_placeholder() -> void:
	var directory := create_temp_dir("sideload/not_png")
	_store("not a png".to_ascii_buffer(), directory.path_join(BALL.file_name))
	assert_object(Sideload.sheet(BALL, directory)).is_same(BALL.placeholder)


func test_a_missing_palette_falls_back_to_the_projects() -> void:
	var directory := create_temp_dir("sideload/missing_palette")
	assert_object(Sideload.palette(MATCH_PALETTE, directory)).is_same(MATCH_PALETTE.fallback)


func test_a_palette_of_the_right_size_is_read_as_it_is() -> void:
	var directory := create_temp_dir("sideload/palette")
	var image := _palette_image(MATCH_PALETTE.image_size())
	image.save_png(directory.path_join(MATCH_PALETTE.file_name))
	var texture := Sideload.palette(MATCH_PALETTE, directory)
	assert_object(texture).is_not_same(MATCH_PALETTE.fallback)
	assert_array(Sideload.read_palette(MATCH_PALETTE, directory).get_data()).is_equal(
		image.get_data()
	)


func test_a_palette_of_the_wrong_size_falls_back_to_the_projects(
	size: Vector2i,
	_test_parameters := [
		[Vector2i(127, 1)], [Vector2i(129, 1)], [Vector2i(128, 2)], [Vector2i(256, 1)]
	]
) -> void:
	var directory := create_temp_dir("sideload/palette_%d_%d" % [size.x, size.y])
	_palette_image(size).save_png(directory.path_join(MATCH_PALETTE.file_name))
	assert_object(Sideload.palette(MATCH_PALETTE, directory)).is_same(MATCH_PALETTE.fallback)


func _sprite(sheet: Texture2D) -> SheetSprite:
	var sprite: SheetSprite = auto_free(SheetSprite.new())
	sprite.description = BALL
	sprite.position = Vector2(100.5, 60.25)
	sprite.show_sheet(sheet)
	return sprite


## Entries 0 to 3, repeating.
func _grey_image(size: Vector2i) -> Image:
	var grey := PackedByteArray()
	grey.resize(size.x * size.y)
	for pixel in grey.size():
		grey[pixel] = pixel % 4
	return Image.create_from_data(size.x, size.y, false, Image.FORMAT_L8, grey)


func _palette_image(size: Vector2i) -> Image:
	var rgb := PackedByteArray()
	rgb.resize(size.x * size.y * 3)
	for byte in rgb.size():
		rgb[byte] = byte % 256
	return Image.create_from_data(size.x, size.y, false, Image.FORMAT_RGB8, rgb)


func _store(bytes: PackedByteArray, path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()
