class_name BallView
extends Node2D
## Draws the ball raised above its shadow, per Showing Height. Reads the ball's
## state and never writes it, so drawing can't change play.

## The shadow layers this much further up the screen than it's drawn.
const SHADOW_LAYER_RAISE := 10.0

var state: BallState

@onready var _ball_layer: Node2D = $BallLayer
@onready var _ball: SheetSprite = $BallLayer/Ball
@onready var _shadow_layer: Node2D = $ShadowLayer
@onready var _shadow: SheetSprite = $ShadowLayer/Shadow


func _process(_delta: float) -> void:
	if state == null:
		return
	# Layered by ground position alone: the layer nodes sit where the sprites
	# sort, and each sprite is drawn from there.
	var shadow_at := shadow_drawn_at(state.position, state.height)
	_ball_layer.position = state.position
	_shadow_layer.position = shadow_at - Vector2(0.0, SHADOW_LAYER_RAISE)
	_ball.place(ball_drawn_at(state.position, state.height))
	_shadow.place(shadow_at)
	_ball.show_cell(frame_column(state, _ball.description))


## Its height higher up the screen than its ground position.
static func ball_drawn_at(ground: Vector2, height: float) -> Vector2:
	return ground - Vector2(0.0, height)


## Right by half the height and down by a quarter, each in whole units rounded
## down, plus one each way — as if lit from the upper left.
static func shadow_drawn_at(ground: Vector2, height: float) -> Vector2:
	return ground + Vector2(floorf(height / 2.0) + 1.0, floorf(height / 4.0) + 1.0)


## The sheet column the ball shows: the roll's current frame while it moves,
## the still frame otherwise.
static func frame_column(ball: BallState, sheet: SheetDescription) -> int:
	if ball.moving:
		return sheet.animations[&"roll"][ball.roll_frame]
	return sheet.animations[&"still"][0]
