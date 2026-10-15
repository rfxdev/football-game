class_name BallTuning
extends Resource
## The ball's values, per Ball Physics and Aerial Simulation. Speeds are world
## units a second; their changes, per second each second. Values live in the
## .tres, never here, per Live Tuning in Playtesting.

@export_group("Height")
## Taken off the vertical speed while the ball is in the air.
@export var gravity: float
## A bounce that leaves this much vertical speed or less ends, and the ball rolls.
@export var bounce_cutoff: float

@export_group("Slowing")
## Taken off the ground speed while the ball is above the ground.
@export var air_slowdown: float
## Taken off the ground speed while it rolls, before the pitch's friction.
@export var ground_slowdown: float

@export_group("Pitch", "pitch_")
## Normal's values, per Pitch Conditions; another surface swaps all three.
@export var pitch_ground_friction: float
## Fraction of the ground speed a bounce takes.
@export var pitch_bounce_speed_lost: float
## Fraction of the vertical speed a bounce keeps.
@export var pitch_bounce_vertical_kept: float

@export_group("Roll", "roll_")
## Ground speeds at which a roll frame's time drops to the next.
@export var roll_speed_limits: PackedFloat64Array
## How long a roll frame lasts, in seconds — one more than the limits, slowest first.
@export var roll_frame_seconds: PackedFloat64Array
