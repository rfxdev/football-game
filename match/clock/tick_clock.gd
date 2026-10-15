class_name TickClock
extends RefCounted
## The simulation's time, in whole physics ticks. Whoever steps the simulation
## owns one and passes it in; nothing reads elapsed time from a global, per
## Determinism in Architecture and Stack.

var tick: int = 0
var ticks_per_second: int


func _init(rate: int) -> void:
	ticks_per_second = rate


func advance() -> void:
	tick += 1


func seconds_per_tick() -> float:
	return 1.0 / ticks_per_second


## A duration in real time as whole ticks, rounded to the nearest, per Writing
## From SWOS.
func ticks_for(seconds: float) -> int:
	return roundi(seconds * ticks_per_second)
