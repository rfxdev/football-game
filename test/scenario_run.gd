class_name ScenarioRun
extends RefCounted
## Steps a [SandboxScenario] headless, running the shared per-tick check on
## every tick, per Invariants in Automation Testing. A test asserts
## [member broken] is empty once it's done stepping.

const TICKS_PER_SECOND := 60

var scenario: SandboxScenario
## Every invariant broken so far, with its tick.
var broken := PackedStringArray()


func _init(
	start: Vector2,
	destination: Vector2,
	speed: float,
	vertical_speed: float,
	goal_mouth := Vector2i(181, 245)
) -> void:
	var tuning: BallTuning = load("res://match/ball/ball_tuning.tres")
	scenario = SandboxScenario.new(tuning, TickClock.new(TICKS_PER_SECOND))
	scenario.start = start
	scenario.destination = destination
	scenario.speed = speed
	scenario.vertical_speed = vertical_speed
	scenario.goal_mouth = goal_mouth
	scenario.reset()


## One tick. Returns why the scenario reset, or an empty name if it didn't.
func step() -> StringName:
	var reason := scenario.step()
	for problem in Invariants.of_ball(scenario.ball):
		broken.append("tick %d: %s" % [scenario.clock.tick, problem])
	return reason


## Steps until the scenario resets or [param limit] ticks pass. Returns why it
## reset, or an empty name if it didn't.
func until_reset(limit: int) -> StringName:
	for _tick in limit:
		var reason := step()
		if reason:
			return reason
	return &""
