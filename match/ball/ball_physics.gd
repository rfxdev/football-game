class_name BallPhysics
## Moves the ball one tick, per Ball Physics and Aerial Simulation: it steps
## toward its destination, slows, rises and falls on a height of its own, and
## picks its roll frame. Called from _physics_process against an injected
## clock, per Determinism in Architecture and Stack.

## Frames in the roll, per Showing Height.
const ROLL_FRAMES := 4
## Directions in a full turn, per Ball Movement, and its parts.
const DIRECTIONS := 256
const HALF_TURN := 128
const QUARTER_TURN := 64
const EIGHTH_TURN := 32
## An offset is halved until both parts are under this.
const OFFSET_LIMIT := 32
## The reference's sine table holds this times the sine, cut to 128ths.
const SINE_SCALE := 32767
const SINE_CUT := 8
const STEP_DIVISOR := 128.0

static var _sine: PackedFloat64Array = _sine_table()


static func step(ball: BallState, tuning: BallTuning, clock: TickClock) -> void:
	var seconds := clock.seconds_per_tick()
	var ground_step := step_toward(ball.position, ball.destination, ball.speed * seconds)
	ball.position += ground_step
	ball.moving = ground_step != Vector2.ZERO
	_slow(ball, tuning, seconds)
	_rise_and_fall(ball, tuning, seconds)
	_roll(ball, tuning, clock)


## Still, on the ground, with nothing left to bounce.
static func is_at_rest(ball: BallState) -> bool:
	return not ball.moving and ball.height == 0.0 and ball.vertical_speed == 0.0


## One tick's move of [param distance] from [param from] toward [param to], in
## the reference's 256 directions. Zero at the point itself.
static func step_toward(from: Vector2, to: Vector2, distance: float) -> Vector2:
	var offset := Vector2i(floori(to.x) - floori(from.x), floori(to.y) - floori(from.y))
	if offset == Vector2i.ZERO:
		return Vector2.ZERO
	var direction := direction_of(offset)
	return Vector2(_sine[(direction + QUARTER_TURN) % DIRECTIONS], _sine[direction]) * distance


## Which of the 256 directions an offset picks, counted from +x toward +y.
## Linear within each eighth of a turn, per Ball Movement.
static func direction_of(offset: Vector2i) -> int:
	var x := absi(offset.x)
	var y := absi(offset.y)
	while x >= OFFSET_LIMIT or y >= OFFSET_LIMIT:
		x >>= 1
		y >>= 1
	var angle := (
		roundi(float(EIGHTH_TURN * y) / x)
		if x >= y
		else QUARTER_TURN - roundi(float(EIGHTH_TURN * x) / y)
	)
	if offset.x < 0:
		angle = HALF_TURN - angle
	if offset.y < 0:
		angle = DIRECTIONS - angle
	return angle % DIRECTIONS


## How many ticks a roll frame holds at [param speed], per Showing Height.
static func roll_frame_ticks(speed: float, tuning: BallTuning, clock: TickClock) -> int:
	var band := 0
	while band < tuning.roll_speed_limits.size() and speed >= tuning.roll_speed_limits[band]:
		band += 1
	return clock.ticks_for(tuning.roll_frame_seconds[band])


static func _slow(ball: BallState, tuning: BallTuning, seconds: float) -> void:
	var slowdown := (
		tuning.air_slowdown
		if ball.height > 0.0
		else tuning.ground_slowdown + tuning.pitch_ground_friction
	)
	ball.speed = maxf(ball.speed - slowdown * seconds, 0.0)


## Gravity waits until the ball has left the ground, per Fake Height, so a kick
## or a bounce lifts it at its full vertical speed.
static func _rise_and_fall(ball: BallState, tuning: BallTuning, seconds: float) -> void:
	if ball.height > 0.0:
		ball.vertical_speed -= tuning.gravity * seconds
	ball.height += ball.vertical_speed * seconds
	if ball.height >= 0.0:
		return
	ball.height = 0.0
	ball.speed *= 1.0 - tuning.pitch_bounce_speed_lost
	ball.vertical_speed *= -tuning.pitch_bounce_vertical_kept
	if ball.vertical_speed <= tuning.bounce_cutoff:
		ball.vertical_speed = 0.0


static func _roll(ball: BallState, tuning: BallTuning, clock: TickClock) -> void:
	if not ball.moving:
		ball.roll_ticks = 0
		return
	if ball.roll_ticks >= roll_frame_ticks(ball.speed, tuning, clock):
		ball.roll_frame = (ball.roll_frame + 1) % ROLL_FRAMES
		ball.roll_ticks = 0
	ball.roll_ticks += 1


static func _sine_table() -> PackedFloat64Array:
	var table := PackedFloat64Array()
	for direction in DIRECTIONS:
		var entry := roundi(SINE_SCALE * sin(TAU * direction / DIRECTIONS))
		# An arithmetic shift rounds down, so a negative part rounds away from zero.
		table.append((entry >> SINE_CUT) / STEP_DIVISOR)
	return table
