extends GdUnitTestSuite
## Showing Height in Ball Physics and Aerial Simulation: where the ball and its
## shadow are drawn for a height, and how long each roll frame lasts.

const TUNING := preload("res://match/ball/ball_tuning.tres")
const TICKS_PER_SECOND := 60


func test_the_ball_is_drawn_its_height_up_the_screen() -> void:
	var ground := Vector2(200.5, 120.25)
	for height: float in [0.0, 0.5, 1.0, 15.0, 19.75, 100.0]:
		(
			assert_vector(BallView.ball_drawn_at(ground, height))
			. append_failure_message("height %s" % height)
			. is_equal(ground - Vector2(0, height))
		)


func test_the_shadow_is_drawn_right_by_half_the_height_and_down_by_a_quarter() -> void:
	# [height, offset from the ground position]: each part in whole units,
	# rounded down, plus one.
	var cases := [
		[0.0, Vector2(1, 1)],
		[1.0, Vector2(1, 1)],
		[1.99, Vector2(1, 1)],
		[2.0, Vector2(2, 1)],
		[3.99, Vector2(2, 1)],
		[4.0, Vector2(3, 2)],
		[7.99, Vector2(4, 2)],
		[8.0, Vector2(5, 3)],
		[15.0, Vector2(8, 4)],
		[100.0, Vector2(51, 26)],
	]
	var ground := Vector2(200.5, 120.25)
	for case: Array in cases:
		(
			assert_vector(BallView.shadow_drawn_at(ground, case[0]))
			. append_failure_message("height %s" % case[0])
			. is_equal(ground + case[1])
		)


func test_a_roll_frame_lasts_its_speeds_time_to_the_tick() -> void:
	# [ground speed, ticks]: 0.12, 0.06, 0.04 and 0.02 seconds at 60 a second.
	var cases := [
		[1.0, 7],
		[49.99, 7],
		[50.0, 4],
		[99.99, 4],
		[100.0, 2],
		[249.99, 2],
		[250.0, 1],
		[1000.0, 1],
	]
	var clock := TickClock.new(TICKS_PER_SECOND)
	for case: Array in cases:
		(
			assert_int(BallPhysics.roll_frame_ticks(case[0], TUNING, clock))
			. append_failure_message("speed %s" % case[0])
			. is_equal(case[1])
		)


func test_a_rolling_ball_holds_each_frame_for_its_speeds_time() -> void:
	# Each speed stays inside its band for the frames measured.
	for case: Array in [[30.0, 7], [75.0, 4], [175.0, 2], [400.0, 1]]:
		var clock := TickClock.new(TICKS_PER_SECOND)
		var ball := BallState.new()
		ball.position = Vector2(100, 100)
		ball.destination = Vector2(1100, 100)
		ball.speed = case[0]
		var shown: Array[int] = []
		for _tick in 3 * case[1]:
			clock.advance()
			BallPhysics.step(ball, TUNING, clock)
			assert_bool(ball.moving).is_true()
			shown.append(ball.roll_frame)
		var expected: Array[int] = []
		for frame in 3:
			for _tick in case[1]:
				expected.append(frame)
		assert_array(shown).append_failure_message("speed %s" % case[0]).is_equal(expected)


func test_the_roll_cycles_through_its_four_frames() -> void:
	var clock := TickClock.new(TICKS_PER_SECOND)
	var ball := BallState.new()
	ball.position = Vector2(100, 100)
	ball.destination = Vector2(1100, 100)
	ball.speed = 400.0
	var shown: Array[int] = []
	for _tick in 6:
		clock.advance()
		BallPhysics.step(ball, TUNING, clock)
		shown.append(ball.roll_frame)
	assert_array(shown).is_equal([0, 1, 2, 3, 0, 1])
