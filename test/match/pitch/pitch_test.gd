extends GdUnitTestSuite
## The out and goal predicates in Pitch and Environment, at each edge. They read
## Pitch's constants, never the frame's numbers, so moving the constants to the
## pitch's lines at 3.0 Pitch and Camera leaves these tests as they are.

const LEFT := Pitch.TOUCHLINE_LEFT + 0.0
## The far edge of each line's own unit, which is in play.
const RIGHT := Pitch.TOUCHLINE_RIGHT + 1.0
const TOP := Pitch.GOAL_LINE_TOP + 0.0
const BOTTOM := Pitch.GOAL_LINE_BOTTOM + 1.0
const JUST := 0.001
## The reference's mouth; any stretch of the line would serve.
const MOUTH := Vector2i(303, 367)


func test_the_ball_is_out_once_past_a_line_and_each_lines_own_unit_is_in() -> void:
	var middle := Vector2((LEFT + RIGHT) / 2, (TOP + BOTTOM) / 2)
	# [ground position, out]
	var cases := [
		[Vector2(LEFT - JUST, middle.y), true],
		[Vector2(LEFT, middle.y), false],
		[Vector2(RIGHT - JUST, middle.y), false],
		[Vector2(RIGHT, middle.y), true],
		[Vector2(middle.x, TOP - JUST), true],
		[Vector2(middle.x, TOP), false],
		[Vector2(middle.x, BOTTOM - JUST), false],
		[Vector2(middle.x, BOTTOM), true],
		[Vector2(LEFT - JUST, TOP - JUST), true],
		[Vector2(LEFT, TOP), false],
		[Vector2(RIGHT - JUST, BOTTOM - JUST), false],
		[Vector2(RIGHT, BOTTOM), true],
	]
	for case: Array in cases:
		assert_bool(Pitch.is_out(case[0])).append_failure_message("at %s" % case[0]).is_equal(
			case[1]
		)


func test_a_goal_is_the_line_crossed_inside_the_mouth_under_the_bar_at_its_edges() -> void:
	var from := float(MOUTH.x)
	var to := MOUTH.y + 1.0
	var inside: Array[float] = [from, from + 0.5, (from + to) / 2, to - JUST]
	var outside: Array[float] = [from - JUST, to, LEFT, RIGHT - JUST]
	var under: Array[float] = [0.0, 1.0, Pitch.BAR_HEIGHT - JUST, Pitch.BAR_HEIGHT]
	var over: Array[float] = [Pitch.BAR_HEIGHT + JUST, Pitch.BAR_HEIGHT + 1.0, 100.0]
	var wrong := PackedStringArray()
	for line in _crossings():
		for x in inside + outside:
			for height in under + over:
				var expected := x in inside and height in under
				var scored := Pitch.is_goal(Vector2(x, line[0]), Vector2(x, line[1]), height, MOUTH)
				if scored != expected:
					wrong.append("x %s, height %s, across y %s: %s" % [x, height, line, scored])
	assert_array(wrong).is_empty()


func test_a_goal_counts_only_on_the_tick_the_line_is_crossed() -> void:
	var x := (MOUTH.x + MOUTH.y) / 2.0
	for line in _crossings():
		# Already past the line, and still short of it.
		assert_bool(Pitch.is_goal(Vector2(x, line[1]), Vector2(x, line[1]), 0.0, MOUTH)).is_false()
		assert_bool(Pitch.is_goal(Vector2(x, line[0]), Vector2(x, line[0]), 0.0, MOUTH)).is_false()


## [y in play just short of a goal line, y just past it], for each goal line.
func _crossings() -> Array:
	return [[TOP, TOP - JUST], [BOTTOM - JUST, BOTTOM]]
