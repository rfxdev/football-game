class_name BallState
extends RefCounted
## Everything about the ball that decides play — data, kept apart from the
## nodes that draw it, per Simulation State in Architecture and Stack.
## Distances are world units; speeds world units a second.

## On the ground, whatever the height.
var position := Vector2.ZERO
## The point the ball heads for, per Ball Movement.
var destination := Vector2.ZERO
## Along the ground.
var speed := 0.0
var height := 0.0
var vertical_speed := 0.0
## Whether the last tick stepped on either axis.
var moving := false
## Which of the roll's frames shows, and for how many ticks it has.
var roll_frame := 0
var roll_ticks := 0
