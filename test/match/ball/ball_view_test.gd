extends GdUnitTestSuite
## How the ball scene draws its state, per Showing Height in Ball Physics and
## Aerial Simulation and Sheets in Sprites: layered by ground position alone,
## showing the frame the state picks, and never writing to the state. Drawn
## from the committed placeholders, never the player's sideload, per Local Data.

const BALL_SCENE := preload("res://match/ball/ball.tscn")
const BALL_SHEET := preload("res://art/sprites/ball.tres")
## The shadow layers this much further up the screen than it's drawn.
const SHADOW_LAYER_RAISE := 10.0


func test_the_ball_layers_at_its_ground_position_and_the_shadow_10_above_where_its_drawn() -> void:
	# [height, the shadow layer's offset from the ground position]: drawn at
	# half and a quarter of the height plus one, then raised 10.
	var cases := [
		[0.0, Vector2(1, 1 - SHADOW_LAYER_RAISE)],
		[3.0, Vector2(2, 1 - SHADOW_LAYER_RAISE)],
		[15.0, Vector2(8, 4 - SHADOW_LAYER_RAISE)],
		[40.0, Vector2(21, 11 - SHADOW_LAYER_RAISE)],
		[100.0, Vector2(51, 26 - SHADOW_LAYER_RAISE)],
	]
	var view := _view()
	var ground := Vector2(200.5, 120.25)
	for case: Array in cases:
		view.state = _state(ground, case[0], false, 0)
		view._process(0.0)
		var height := "height %s" % case[0]
		assert_vector(_ball_layer(view).position).append_failure_message(height).is_equal(ground)
		assert_vector(_shadow_layer(view).position).append_failure_message(height).is_equal(
			ground + case[1]
		)


func test_the_ball_shows_the_frame_its_state_picks() -> void:
	var view := _view()
	var ground := Vector2(200.5, 120.25)
	# Moving: the roll's frame. Still: the still frame, whatever the roll had.
	for frame in 4:
		view.state = _state(ground, 0.0, true, frame)
		view._process(0.0)
		(
			assert_that(_ball_sprite(view).region_rect)
			. append_failure_message("rolling %d" % frame)
			. is_equal(Rect2(BALL_SHEET.cell_rect(BALL_SHEET.animations[&"roll"][frame], 0)))
		)
		view.state = _state(ground, 0.0, false, frame)
		view._process(0.0)
		(
			assert_that(_ball_sprite(view).region_rect)
			. append_failure_message("still %d" % frame)
			. is_equal(Rect2(BALL_SHEET.cell_rect(BALL_SHEET.animations[&"still"][0], 0)))
		)


func test_drawing_never_changes_the_balls_state() -> void:
	var view := _view()
	for height: float in [0.0, 12.5, 60.0]:
		var state := _state(Vector2(100.75, 80.5), height, true, 2)
		state.destination = Vector2(1100, 80)
		state.speed = 150.0
		state.vertical_speed = -20.0
		state.roll_ticks = 1
		var before := _fields(state)
		view.state = state
		for _frame in 3:
			view._process(0.0)
		assert_array(_fields(state)).append_failure_message("height %s" % height).is_equal(before)


## The ball scene in the tree, its sprites on the committed placeholders so
## nothing reads the sideload. Tests draw it by calling its _process rather
## than waiting on a frame, so each assertion sees the state just set.
func _view() -> BallView:
	var view: BallView = auto_free(BALL_SCENE.instantiate())
	for path in ["BallLayer/Ball", "ShadowLayer/Shadow"]:
		var sprite: SheetSprite = view.get_node(path)
		sprite.show_sheet(sprite.description.placeholder)
	add_child(view)
	return view


func _state(ground: Vector2, height: float, moving: bool, roll_frame: int) -> BallState:
	var state := BallState.new()
	state.position = ground
	state.destination = ground
	state.height = height
	state.moving = moving
	state.roll_frame = roll_frame
	return state


func _fields(state: BallState) -> Array:
	return [
		state.position,
		state.destination,
		state.speed,
		state.height,
		state.vertical_speed,
		state.moving,
		state.roll_frame,
		state.roll_ticks,
	]


func _ball_layer(view: BallView) -> Node2D:
	return view.get_node("BallLayer")


func _shadow_layer(view: BallView) -> Node2D:
	return view.get_node("ShadowLayer")


func _ball_sprite(view: BallView) -> SheetSprite:
	return view.get_node("BallLayer/Ball")
