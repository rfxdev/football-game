extends Node2D
## The sandbox, per 0.2 Sandbox Scene: one ball in a fixed frame, and a goal
## mouth on each goal line. The scenario is set in the Inspector and resets when
## the ball goes out, scores or comes to rest. Tune the ball live from the
## Remote tree, per Live Tuning in Playtesting; a changed scenario takes effect
## at the next reset.

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

var _scenario: SandboxScenario

@onready var _view: BallView = $World/Ball


func _ready() -> void:
	_scenario = SandboxScenario.new(tuning, TickClock.new(Engine.physics_ticks_per_second))
	_configure()
	_scenario.reset()
	_view.state = _scenario.ball


func _physics_process(_delta: float) -> void:
	_configure()
	var reason := _scenario.step()
	if reason:
		print("Tick %d: %s, reset" % [_scenario.clock.tick, reason])
		_view.state = _scenario.ball


func _configure() -> void:
	_scenario.start = start
	_scenario.destination = destination
	_scenario.speed = speed
	_scenario.vertical_speed = vertical_speed
	_scenario.goal_mouth = Vector2i(goal_mouth_from, goal_mouth_to)
	_scenario.tuning = tuning
