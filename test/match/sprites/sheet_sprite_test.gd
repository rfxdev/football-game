extends GdUnitTestSuite
## Sheets in Sprites: every cell of a sheet draws with its anchor at the
## sprite's position. Synthetic sheets only, per Local Data.

const BALL := preload("res://art/sprites/ball.tres")
const BALL_SHADOW := preload("res://art/sprites/ball_shadow.tres")


func test_every_cell_draws_its_anchor_at_the_sprite_position() -> void:
	for description: SheetDescription in [BALL, BALL_SHADOW, _uneven_description()]:
		var sheet := _marked_sheet(description)
		var sprite: SheetSprite = auto_free(SheetSprite.new())
		sprite.description = description
		sprite.position = Vector2(40.25, 30.5)
		sprite.show_sheet(ImageTexture.create_from_image(sheet))
		for row in description.rows:
			for column in description.columns:
				sprite.show_cell(column, row)
				var drawn_at := sprite.transform * sprite.get_rect().position
				var texel := Vector2i(sprite.region_rect.position) + description.anchor
				# The anchor's pixel lands on the sprite's position...
				assert_vector(drawn_at + Vector2(description.anchor)).is_equal(sprite.position)
				# ...and it is this cell's anchor, not a neighbour's.
				assert_int(_entry(sheet, texel)).is_equal(_marker(description, column, row))
				assert_vector(sprite.get_rect().size).is_equal(Vector2(description.cell_size))


## Not square, anchor off-centre, more than one row: catches x and y swapped.
func _uneven_description() -> SheetDescription:
	var description := SheetDescription.new()
	description.cell_size = Vector2i(5, 3)
	description.anchor = Vector2i(3, 1)
	description.columns = 3
	description.rows = 2
	return description


## Every pixel 0 except each cell's anchor, which holds a value unique to it.
func _marked_sheet(description: SheetDescription) -> Image:
	var size := description.sheet_size()
	var grey := PackedByteArray()
	grey.resize(size.x * size.y)
	for row in description.rows:
		for column in description.columns:
			var anchor := description.cell_rect(column, row).position + description.anchor
			grey[anchor.y * size.x + anchor.x] = _marker(description, column, row)
	return Image.create_from_data(size.x, size.y, false, Image.FORMAT_L8, grey)


func _marker(description: SheetDescription, column: int, row: int) -> int:
	return 1 + row * description.columns + column


func _entry(sheet: Image, texel: Vector2i) -> int:
	return sheet.get_data()[texel.y * sheet.get_width() + texel.x]
