class_name Invariants
## The shared per-tick check, per Invariants in Automation Testing: what no tick
## may break, whatever a test is testing. Each milestone adds what it
## introduces — the ball's from 0.3 Ball Physics Test Suite.


## Everything wrong with [param ball] after a tick; empty if nothing is.
static func of_ball(ball: BallState) -> PackedStringArray:
	var broken := PackedStringArray()
	if not ball.position.is_finite():
		broken.append("position %s isn't a number" % ball.position)
	# Written so a NaN height fails too.
	if not (ball.height >= 0.0):
		broken.append("height %s is below 0" % ball.height)
	if Pitch.is_out(ball.position):
		broken.append("out at %s and not reset" % ball.position)
	return broken
