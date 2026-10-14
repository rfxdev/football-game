extends Label
## Shows what the Input Map reports for each control in the Player Manual's
## table, so a device can be checked by eye. Display only — reads named
## actions, never a device.


func _process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var button: String = "held" if Input.is_action_pressed(&"action") else "-"
	text = "Move    %+.2f, %+.2f\nButton  %s" % [direction.x, direction.y, button]
