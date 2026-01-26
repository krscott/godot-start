class_name PlayerInput
const gdserde_class := &"PlayerInput"

# TODO: Make parameter
const sensitivity := 0.2
const min_angle := -90.0
const max_angle := 90


var look := Vector2.ZERO
var move := Vector2.ZERO
var sprint := false
var crouch := false
var jump := false

func update_physics_from_input() -> void:
	move = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward"
	)
	sprint = Input.is_action_pressed("sprint")
	crouch = Input.is_action_pressed("crouch")
	jump = Input.is_action_pressed("jump")


func update_view_from_event(event: InputEvent) -> void:
	match event.get_class():
		"InputEventMouseMotion":
			var ev: InputEventMouseMotion = event
			look.y -= (ev.relative.x * sensitivity)
			look.x -= (ev.relative.y * sensitivity)
			look.x = clamp(look.x, min_angle, max_angle)
		"InputEventKey", "InputEventMouseButton":
			pass
