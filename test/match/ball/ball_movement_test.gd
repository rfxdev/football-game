extends GdUnitTestSuite
## Ball Movement in Ball Physics and Aerial Simulation: the ball heads for its
## point, re-aimed every tick, in one of 256 directions picked by a rule that's
## linear within each eighth of a turn.

const TUNING := preload("res://match/ball/ball_tuning.tres")
const TICKS_PER_SECOND := 60
## Normal's ground slowdown, per Fake Height.
const GROUND_SLOWDOWN := 78.0
## A point far out along each axis, as a kick's is.
const AXES: Array[Vector2] = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]


func test_offsets_pick_the_directions_the_rule_gives() -> void:
	# [offset, direction]: counted from +x toward +y, in 256ths of a turn.
	var cases := [
		[Vector2i(1, 0), 0],
		[Vector2i(1, 1), 32],
		[Vector2i(0, 1), 64],
		[Vector2i(-1, 1), 96],
		[Vector2i(-1, 0), 128],
		[Vector2i(-1, -1), 160],
		[Vector2i(0, -1), 192],
		[Vector2i(1, -1), 224],
		# Halfway between an axis and a diagonal: 16, about 4° nearer the axis.
		[Vector2i(2, 1), 16],
		# 32 × 1 ÷ 3 rounds to 11, in each quadrant.
		[Vector2i(3, 1), 11],
		[Vector2i(-3, 1), 117],
		[Vector2i(3, -1), 245],
		[Vector2i(1, 3), 53],
		[Vector2i(-1, -3), 181],
		# Halved, rounding down, until both parts are under 32.
		[Vector2i(31, 31), 32],
		[Vector2i(32, 0), 0],
		[Vector2i(64, 33), 16],
		[Vector2i(-64, -33), 144],
		[Vector2i(100, -7), 255],
	]
	for case: Array in cases:
		(
			assert_int(BallPhysics.direction_of(case[0]))
			. append_failure_message("offset %s" % case[0])
			. is_equal(case[1])
		)


func test_every_offset_picks_the_direction_the_rule_gives() -> void:
	var wrong := PackedStringArray()
	for x in range(-100, 101):
		for y in range(-100, 101):
			var offset := Vector2i(x, y)
			if offset == Vector2i.ZERO:
				continue
			var picked := BallPhysics.direction_of(offset)
			if picked != _by_the_rule(offset):
				wrong.append("%s picked %d, not %d" % [offset, picked, _by_the_rule(offset)])
	assert_array(wrong).is_empty()


func test_a_step_is_the_speed_cut_to_128ths_rounding_down() -> void:
	# 120 a second is 2 a tick. [offset, step]: a positive part rounds down to
	# 127/128 along an axis and 90/128 on a diagonal; a negative one rounds away
	# from zero, to 128/128 and 91/128.
	var cases := [
		[Vector2i(1, 0), Vector2(2.0 * 127 / 128, 0)],
		[Vector2i(-1, 0), Vector2(-2.0, 0)],
		[Vector2i(0, 1), Vector2(0, 2.0 * 127 / 128)],
		[Vector2i(0, -1), Vector2(0, -2.0)],
		[Vector2i(1, 1), Vector2(2.0 * 90 / 128, 2.0 * 90 / 128)],
		[Vector2i(-1, 1), Vector2(-2.0 * 91 / 128, 2.0 * 90 / 128)],
		[Vector2i(-1, -1), Vector2(-2.0 * 91 / 128, -2.0 * 91 / 128)],
		[Vector2i(1, -1), Vector2(2.0 * 90 / 128, -2.0 * 91 / 128)],
		# Direction 16: cos and sin of 22.5° are 118/128 and 48/128.
		[Vector2i(2, 1), Vector2(2.0 * 118 / 128, 2.0 * 48 / 128)],
	]
	var from := Vector2(100.5, 100.5)
	for case: Array in cases:
		var offset: Vector2i = case[0]
		(
			assert_vector(BallPhysics.step_toward(from, from + Vector2(offset), 2.0))
			. append_failure_message("offset %s" % offset)
			. is_equal_approx(case[1], Vector2(1e-6, 1e-6))
		)


func test_the_offset_is_taken_between_whole_units() -> void:
	# 0.9 apart, but in the same unit: no offset, so no step.
	(
		assert_vector(BallPhysics.step_toward(Vector2(10.05, 20.05), Vector2(10.95, 20.95), 2.0))
		. is_equal(Vector2.ZERO)
	)
	# 0.1 apart, but across a unit boundary: a whole unit's offset.
	(
		assert_vector(BallPhysics.step_toward(Vector2(10.95, 20.5), Vector2(11.05, 20.5), 2.0))
		. is_equal_approx(Vector2(2.0 * 127 / 128, 0), Vector2(1e-6, 1e-6))
	)


func test_a_ball_heading_along_an_axis_never_leaves_its_line() -> void:
	# Bouncing and slowing included: nothing but the point moves it off.
	for axis in AXES:
		var clock := TickClock.new(TICKS_PER_SECOND)
		var start := Vector2(213.5, 133.25)
		var ball := _ball(start, start + axis * 1000.0, 400.0, 150.0)
		var along := 0.0
		for _tick in 240:
			clock.advance()
			BallPhysics.step(ball, TUNING, clock)
			var travelled := (ball.position - start).dot(axis)
			(
				assert_float((ball.position - start).dot(axis.orthogonal()))
				. append_failure_message("along %s, tick %d" % [axis, clock.tick])
				. is_equal(0.0)
			)
			(
				assert_float(travelled)
				. append_failure_message("along %s, tick %d" % [axis, clock.tick])
				. is_greater_equal(along)
			)
			along = travelled
		assert_float(along).append_failure_message("along %s" % axis).is_greater(0.0)


func test_moving_the_point_bends_the_path_toward_it() -> void:
	for side: float in [1.0, -1.0]:
		var clock := TickClock.new(TICKS_PER_SECOND)
		var ball := _ball(Vector2(100, 133), Vector2(1100, 133), 300.0, 0.0)
		for _tick in 20:
			clock.advance()
			BallPhysics.step(ball, TUNING, clock)
		assert_float(ball.position.y).is_equal(133.0)
		ball.destination = Vector2(1100, 133 + side * 500)
		var sideways := 0.0
		for _tick in 20:
			clock.advance()
			BallPhysics.step(ball, TUNING, clock)
			var now := (ball.position.y - 133) * side
			(
				assert_float(now)
				. append_failure_message("side %s, tick %d" % [side, clock.tick])
				. is_greater(sideways)
			)
			sideways = now


func test_a_ball_at_its_point_stays_there_and_only_slowing_takes_its_speed() -> void:
	var clock := TickClock.new(TICKS_PER_SECOND)
	# The same whole unit as its point, so the offset is zero.
	var ball := _ball(Vector2(200.25, 150.75), Vector2(200.9, 150.1), 100.0, 0.0)
	clock.advance()
	BallPhysics.step(ball, TUNING, clock)
	assert_vector(ball.position).is_equal(Vector2(200.25, 150.75))
	assert_bool(ball.moving).is_false()
	assert_float(ball.speed).is_equal_approx(100.0 - GROUND_SLOWDOWN / TICKS_PER_SECOND, 1e-9)


## The direction for [param offset] by Ball Movement's rule as written: the
## angle from the nearer axis is 32 × the smaller part ÷ the larger, rounded,
## once both are halved under 32; then placed in the offset's quadrant.
func _by_the_rule(offset: Vector2i) -> int:
	var across := absi(offset.x)
	var down := absi(offset.y)
	while maxi(across, down) >= 32:
		across = floori(across / 2.0)
		down = floori(down / 2.0)
	var from_axis := roundi(32.0 * mini(across, down) / maxi(across, down))
	# From +x within the quadrant, then mirrored into the offset's own.
	var from_x := from_axis if across >= down else 64 - from_axis
	if offset.x < 0:
		from_x = 128 - from_x
	if offset.y < 0:
		from_x = 256 - from_x
	return from_x % 256


func _ball(
	position: Vector2, destination: Vector2, speed: float, vertical_speed: float
) -> BallState:
	var ball := BallState.new()
	ball.position = position
	ball.destination = destination
	ball.speed = speed
	ball.vertical_speed = vertical_speed
	return ball
