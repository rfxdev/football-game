class_name Pitch
## The lines the ball is tested against, per The Pitch and The Goal in Pitch and
## Environment — constants, never the size of anything drawn. Until 3.0 Pitch
## and Camera they are the sandbox frame's edges, 426 × 266; 3.0 moves them to
## the pitch's lines and leaves the predicates alone.

## Each line's own unit is in play.
const TOUCHLINE_LEFT := 0
const TOUCHLINE_RIGHT := 425
const GOAL_LINE_TOP := 0
const GOAL_LINE_BOTTOM := 265
## A goal goes in no higher than this.
const BAR_HEIGHT := 15.0


## Whether the ball is past a line, at any height.
static func is_out(ground: Vector2) -> bool:
	return _past_touchline(ground) or _past_goal_line(ground)


## Whether the tick from [param previous] to [param ground] crossed a goal line
## inside the mouth, under the bar. The mouth runs across the goal line from
## [code]mouth.x[/code] to [code]mouth.y[/code], each end's unit inside it.
static func is_goal(previous: Vector2, ground: Vector2, height: float, mouth: Vector2i) -> bool:
	if _past_goal_line(previous) or not _past_goal_line(ground):
		return false
	return ground.x >= mouth.x and ground.x < mouth.y + 1 and height <= BAR_HEIGHT


static func _past_touchline(ground: Vector2) -> bool:
	return ground.x < TOUCHLINE_LEFT or ground.x >= TOUCHLINE_RIGHT + 1


static func _past_goal_line(ground: Vector2) -> bool:
	return ground.y < GOAL_LINE_TOP or ground.y >= GOAL_LINE_BOTTOM + 1
