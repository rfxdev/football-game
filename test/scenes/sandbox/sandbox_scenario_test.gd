extends GdUnitTestSuite
## The sandbox's drill run headless, per 0.2 Sandbox Scene: what a crossing
## comes to, Determinism in Automation Testing, and the shared per-tick check
## under scenarios across the frame. Every run asserts no invariant broke.

const LIMIT := 1200
## The sandbox's own mouth, across both goal lines.
const MOUTH := Vector2i(181, 245)
## World units a second: high enough at the line to clear the bar.
const LOFTED := 300.0


func test_every_goal_line_crossing_is_exactly_one_of_a_goal_or_out() -> void:
	# [x, in the mouth]: each end's unit is inside it.
	var columns := [
		[100.0, false],
		[180.5, false],
		[181.5, true],
		[213.0, true],
		[245.5, true],
		[246.5, false],
		[400.0, false],
	]
	# [start y, point y]: up toward the top line, and down toward the bottom.
	var runs := [[60.0, -1000.0], [Pitch.GOAL_LINE_BOTTOM - 59.0, 1000.0 + Pitch.GOAL_LINE_BOTTOM]]
	for column: Array in columns:
		for run_to: Array in runs:
			for vertical_speed: float in [0.0, LOFTED]:
				var x: float = column[0]
				var run := ScenarioRun.new(
					Vector2(x, run_to[0]), Vector2(x, run_to[1]), 300.0, vertical_speed, MOUTH
				)
				var expected := (
					SandboxScenario.GOAL
					if column[1] and vertical_speed == 0.0
					else SandboxScenario.OUT
				)
				var what := "x %s toward y %s, rising at %s" % [x, run_to[1], vertical_speed]
				assert_str(run.until_reset(LIMIT)).append_failure_message(what).is_equal(expected)
				assert_array(run.broken).append_failure_message(what).is_empty()


func test_a_ball_past_a_touchline_is_out_at_any_height() -> void:
	for vertical_speed: float in [0.0, 100.0, LOFTED, 1000.0]:
		for toward: float in [-1000.0, 1000.0 + Pitch.TOUCHLINE_RIGHT]:
			var run := ScenarioRun.new(
				Vector2(213, 133), Vector2(toward, 133), 600.0, vertical_speed
			)
			var what := "toward x %s, rising at %s" % [toward, vertical_speed]
			assert_str(run.until_reset(LIMIT)).append_failure_message(what).is_equal(
				SandboxScenario.OUT
			)
			assert_array(run.broken).append_failure_message(what).is_empty()


func test_a_ball_rolled_short_of_every_line_resets_at_rest() -> void:
	# 200 along the ground stops about 256 on, well inside the frame.
	var run := ScenarioRun.new(Vector2(100, 133), Vector2(1100, 133), 200.0, 0.0)
	assert_str(run.until_reset(LIMIT)).is_equal(SandboxScenario.AT_REST)
	assert_array(run.broken).is_empty()


func test_the_same_scenario_run_twice_ends_in_the_same_state() -> void:
	for setup: Array in _scenarios(12):
		var first := _run(setup)
		var second := _run(setup)
		var differs := PackedStringArray()
		for _tick in LIMIT:
			var reasons := [first.step(), second.step()]
			if reasons[0] != reasons[1] or _fields(first) != _fields(second):
				differs.append(
					(
						"tick %d: %s against %s"
						% [first.scenario.clock.tick, _fields(first), _fields(second)]
					)
				)
				break
		assert_array(differs).append_failure_message("setup %s" % [setup]).is_empty()
		assert_array(first.broken).append_failure_message("setup %s" % [setup]).is_empty()


func test_no_scenario_across_the_frame_breaks_an_invariant() -> void:
	for setup: Array in _scenarios(200):
		var run := _run(setup)
		for _tick in LIMIT:
			run.step()
		assert_array(run.broken).append_failure_message("setup %s" % [setup]).is_empty()


## [start, point, speed, vertical speed] for ScenarioRun, spread across the
## frame and every heading, each starting in play. Seeded, so every run draws
## the same set.
func _scenarios(count: int) -> Array[Array]:
	var random := RandomNumberGenerator.new()
	random.seed = 3
	var scenarios: Array[Array] = []
	for _scenario in count:
		var start := Vector2(
			random.randf_range(Pitch.TOUCHLINE_LEFT, Pitch.TOUCHLINE_RIGHT + 0.5),
			random.randf_range(Pitch.GOAL_LINE_TOP, Pitch.GOAL_LINE_BOTTOM + 0.5)
		)
		var heading := Vector2.from_angle(random.randf_range(0.0, TAU))
		var reach := random.randf_range(1.0, 1500.0)
		scenarios.append(
			[
				start,
				start + heading * reach,
				random.randf_range(0.0, 800.0),
				random.randf_range(0.0, 500.0)
			]
		)
	return scenarios


func _run(setup: Array) -> ScenarioRun:
	return ScenarioRun.new(setup[0], setup[1], setup[2], setup[3])


func _fields(run: ScenarioRun) -> Array:
	var ball := run.scenario.ball
	return [
		ball.position,
		ball.destination,
		ball.speed,
		ball.height,
		ball.vertical_speed,
		ball.moving,
		ball.roll_frame,
		ball.roll_ticks,
	]
