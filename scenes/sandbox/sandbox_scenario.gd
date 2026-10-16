class_name SandboxScenario
extends RefCounted
## The sandbox's drill, per 0.2 Sandbox Scene: one ball, set going from the same
## start each time, and reset when it scores, goes out or comes to rest. The
## sandbox steps it each physics tick; tests step it headless.

const GOAL := &"goal"
const OUT := &"out"
const AT_REST := &"at rest"

## On the ground.
var start: Vector2
## The point the ball heads for, per Ball Movement.
var destination: Vector2
## Along the ground, world units a second.
var speed: float
## World units a second; 0 starts the ball rolling.
var vertical_speed: float
## The goal mouth's ends across each goal line, each end's unit inside it.
var goal_mouth: Vector2i
var tuning: BallTuning
var clock: TickClock
var ball: BallState


func _init(ball_tuning: BallTuning, tick_clock: TickClock) -> void:
	tuning = ball_tuning
	clock = tick_clock


## Moves the ball one tick. Returns why the scenario reset, or an empty name if
## it didn't. The goal is checked before out, since a goal's crossing is past
## the line too: one predicate, read by both, per The Goal.
func step() -> StringName:
	clock.advance()
	var previous := ball.position
	BallPhysics.step(ball, tuning, clock)
	var reason := &""
	if Pitch.is_goal(previous, ball.position, ball.height, goal_mouth):
		reason = GOAL
	elif Pitch.is_out(ball.position):
		reason = OUT
	elif BallPhysics.is_at_rest(ball):
		reason = AT_REST
	if reason:
		reset()
	return reason


func reset() -> void:
	ball = BallState.new()
	ball.position = start
	ball.destination = destination
	ball.speed = speed
	ball.vertical_speed = vertical_speed
