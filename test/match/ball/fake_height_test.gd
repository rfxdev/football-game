extends GdUnitTestSuite
## Fake Height and Pitch Conditions in Ball Physics and Aerial Simulation: the
## ball's own height and vertical speed, gravity, the two slowdowns, and the
## normal pitch's bounce. Values are the doc's, measured from what the ball
## does, never read back from the tuning Resource.

const TUNING := preload("res://match/ball/ball_tuning.tres")
const TICKS_PER_SECOND := 60
const GRAVITY := 176.0
const AIR_SLOWDOWN := 49.0
const GROUND_SLOWDOWN := 78.0
const BOUNCE_CUTOFF := 31.0
## Normal's, per Pitch Conditions.
const BOUNCE_SPEED_LOST := 0.25
const BOUNCE_VERTICAL_KEPT := 0.625
const TOLERANCE := 1e-9


func test_gravity_waits_until_the_ball_has_left_the_ground() -> void:
	var clock := TickClock.new(TICKS_PER_SECOND)
	var ball := _ball(0.0, 150.0, 0.0)
	clock.advance()
	BallPhysics.step(ball, TUNING, clock)
	assert_float(ball.vertical_speed).is_equal(150.0)
	assert_float(ball.height).is_equal_approx(150.0 / TICKS_PER_SECOND, TOLERANCE)


func test_gravity_takes_its_value_off_every_tick_in_the_air() -> void:
	var clock := TickClock.new(TICKS_PER_SECOND)
	var ball := _ball(0.0, 150.0, 0.0)
	var expected := 150.0
	while true:
		var in_the_air := ball.height > 0.0
		clock.advance()
		BallPhysics.step(ball, TUNING, clock)
		if ball.height == 0.0:
			break
		if in_the_air:
			expected -= GRAVITY / TICKS_PER_SECOND
		(
			assert_float(ball.vertical_speed)
			. append_failure_message("tick %d" % clock.tick)
			. is_equal_approx(expected, TOLERANCE)
		)
	assert_int(clock.tick).is_greater(2)


func test_a_ball_let_go_in_the_air_falls() -> void:
	var clock := TickClock.new(TICKS_PER_SECOND)
	var ball := _ball(20.0, 0.0, 0.0)
	clock.advance()
	BallPhysics.step(ball, TUNING, clock)
	assert_float(ball.vertical_speed).is_equal_approx(-GRAVITY / TICKS_PER_SECOND, TOLERANCE)
	assert_float(ball.height).is_less(20.0)


func test_ground_speed_falls_at_the_air_rate_at_every_height_above_0() -> void:
	# Rising, so none of them reaches the ground this tick.
	for height: float in [0.001, 0.5, 15.0, 15.001, 19.0, 100.0, 1000.0]:
		var clock := TickClock.new(TICKS_PER_SECOND)
		var ball := _ball(height, 10.0, 200.0)
		clock.advance()
		BallPhysics.step(ball, TUNING, clock)
		assert_float(ball.speed).append_failure_message("height %s" % height).is_equal_approx(
			200.0 - AIR_SLOWDOWN / TICKS_PER_SECOND, TOLERANCE
		)


func test_ground_speed_falls_at_the_ground_rate_on_the_ground() -> void:
	var clock := TickClock.new(TICKS_PER_SECOND)
	var ball := _ball(0.0, 0.0, 200.0)
	clock.advance()
	BallPhysics.step(ball, TUNING, clock)
	assert_float(ball.speed).is_equal_approx(200.0 - GROUND_SLOWDOWN / TICKS_PER_SECOND, TOLERANCE)


func test_slowing_stops_at_a_standstill() -> void:
	var clock := TickClock.new(TICKS_PER_SECOND)
	var ball := _ball(0.0, 0.0, 0.5)
	clock.advance()
	BallPhysics.step(ball, TUNING, clock)
	assert_float(ball.speed).is_equal(0.0)


func test_a_rolled_ball_stops_when_the_ground_rate_says_and_stays_stopped() -> void:
	var clock := TickClock.new(TICKS_PER_SECOND)
	var ball := _ball(0.0, 0.0, 200.0)
	# The speed lasts this many ticks of slowing; the tick after, it takes no step.
	var stops_on := ceili(200.0 / (GROUND_SLOWDOWN / TICKS_PER_SECOND)) + 1
	# A new ball isn't moving yet, so step before asking whether it's at rest.
	clock.advance()
	BallPhysics.step(ball, TUNING, clock)
	while not BallPhysics.is_at_rest(ball) and clock.tick < 1000:
		clock.advance()
		BallPhysics.step(ball, TUNING, clock)
	assert_int(clock.tick).is_equal(stops_on)
	var stopped_at := ball.position
	for _tick in 120:
		clock.advance()
		BallPhysics.step(ball, TUNING, clock)
		var tick := "tick %d" % clock.tick
		assert_vector(ball.position).append_failure_message(tick).is_equal(stopped_at)
		assert_bool(ball.moving).append_failure_message(tick).is_false()
		assert_float(ball.speed).append_failure_message(tick).is_equal(0.0)
		assert_float(ball.height).append_failure_message(tick).is_equal(0.0)


func test_a_bounce_takes_its_share_of_ground_speed_and_keeps_its_share_of_vertical() -> void:
	# Both start just off the ground and slow at the air rate this tick; only
	# the falling one bounces.
	var clock := TickClock.new(TICKS_PER_SECOND)
	var falling := _ball(0.01, -50.0, 100.0)
	var rising := _ball(0.01, 50.0, 100.0)
	clock.advance()
	BallPhysics.step(falling, TUNING, clock)
	BallPhysics.step(rising, TUNING, clock)
	assert_float(falling.height).is_equal(0.0)
	assert_float(rising.height).is_greater(0.0)
	assert_float(falling.speed).is_equal_approx(rising.speed * (1.0 - BOUNCE_SPEED_LOST), TOLERANCE)
	# Gravity first takes its tick, then the bounce flips what's left.
	assert_float(falling.vertical_speed).is_equal_approx(
		(50.0 + GRAVITY / TICKS_PER_SECOND) * BOUNCE_VERTICAL_KEPT, TOLERANCE
	)


func test_a_bounce_leaving_the_cutoff_or_less_ends_and_the_ball_rolls() -> void:
	# [vertical speed the bounce leaves, what the ball keeps]
	for case: Array in [[BOUNCE_CUTOFF - 0.01, 0.0], [BOUNCE_CUTOFF + 0.01, BOUNCE_CUTOFF + 0.01]]:
		var left: float = case[0]
		var clock := TickClock.new(TICKS_PER_SECOND)
		var falling := -left / BOUNCE_VERTICAL_KEPT + GRAVITY / TICKS_PER_SECOND
		var ball := _ball(0.01, falling, 100.0)
		clock.advance()
		BallPhysics.step(ball, TUNING, clock)
		assert_float(ball.height).append_failure_message("leaving %s" % left).is_equal(0.0)
		(
			assert_float(ball.vertical_speed)
			. append_failure_message("leaving %s" % left)
			. is_equal_approx(case[1], 1e-6)
		)
		clock.advance()
		BallPhysics.step(ball, TUNING, clock)
		if case[1] == 0.0:
			assert_float(ball.height).append_failure_message("leaving %s" % left).is_equal(0.0)
		else:
			assert_float(ball.height).append_failure_message("leaving %s" % left).is_greater(0.0)


func test_a_dropped_ball_bounces_lower_each_time_and_comes_to_rest_without_jittering() -> void:
	var clock := TickClock.new(TICKS_PER_SECOND)
	var ball := _ball(40.0, 0.0, 150.0)
	var peaks: Array[float] = [40.0]
	var settled_at := -1
	while not BallPhysics.is_at_rest(ball) and clock.tick < 1000:
		clock.advance()
		BallPhysics.step(ball, TUNING, clock)
		if settled_at >= 0:
			assert_float(ball.height).append_failure_message("tick %d" % clock.tick).is_equal(0.0)
			(
				assert_float(ball.vertical_speed)
				. append_failure_message("tick %d" % clock.tick)
				. is_equal(0.0)
			)
		elif ball.height == 0.0 and ball.vertical_speed == 0.0:
			settled_at = clock.tick
		elif ball.height == 0.0:
			peaks.append(0.0)
		else:
			peaks[-1] = maxf(peaks[-1], ball.height)
	assert_int(settled_at).is_greater(0)
	assert_bool(BallPhysics.is_at_rest(ball)).is_true()
	assert_int(peaks.size()).is_greater(1)
	for bounce in range(1, peaks.size()):
		assert_float(peaks[bounce]).append_failure_message("bounce %d" % bounce).is_less(
			peaks[bounce - 1]
		)


## Heading far along +x, so it moves in a straight line.
func _ball(height: float, vertical_speed: float, speed: float) -> BallState:
	var ball := BallState.new()
	ball.position = Vector2(100, 100)
	ball.destination = Vector2(1100, 100)
	ball.height = height
	ball.vertical_speed = vertical_speed
	ball.speed = speed
	return ball
