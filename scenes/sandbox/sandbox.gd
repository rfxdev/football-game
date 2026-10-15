extends Node2D
## The sandbox, per 0.2 Sandbox Scene: one ball in a fixed frame, and a goal
## mouth on each goal line. The scenario is set in the Inspector and resets when
## the ball goes out, scores or comes to rest. Tune the ball live from the
## Remote tree, per Live Tuning in Playtesting.

## On the ground.
@export var start: Vector2
## The point the ball heads for, per Ball Movement.
@export var destination: Vector2
## Along the ground, world units a second.
@export var speed: float
## World units a second; 0 starts the ball rolling.
@export var vertical_speed: float
## The goal mouth's ends across each goal line, each end's unit inside it.
@export var goal_mouth_from: int
@export var goal_mouth_to: int
@export var tuning: BallTuning

var _clock: TickClock
var _ball: BallState

@onready var _view: BallView = $World/Ball


func _ready() -> void:
	_clock = TickClock.new(Engine.physics_ticks_per_second)
	_reset()


func _physics_process(_delta: float) -> void:
	_clock.advance()
	var previous := _ball.position
	BallPhysics.step(_ball, tuning, _clock)
	var mouth := Vector2i(goal_mouth_from, goal_mouth_to)
	if Pitch.is_goal(previous, _ball.position, _ball.height, mouth):
		_reset("goal")
	elif Pitch.is_out(_ball.position):
		_reset("out")
	elif BallPhysics.is_at_rest(_ball):
		_reset("at rest")


func _reset(reason: String = "") -> void:
	if reason:
		print("Tick %d: %s, reset" % [_clock.tick, reason])
	_ball = BallState.new()
	_ball.position = start
	_ball.destination = destination
	_ball.speed = speed
	_ball.vertical_speed = vertical_speed
	_view.state = _ball
