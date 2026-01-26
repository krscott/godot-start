extends Camera3D
class_name FreeCam
const gdserde_class := &"FreeCam"
const gdserde_props := [&"transform"]

@export
var base_speed := 0.05
@export
var sprint_speed := 0.2


func apply_view_input(input: PlayerInput) -> void:
	rotation_degrees.x = input.look.x
	rotation_degrees.y = input.look.y


func apply_physics_input(input: PlayerInput) -> void:
	var updown := 0.0
	if input.jump:
		updown += 1.0
	if input.crouch:
		updown -= 1.0
	
	var speed := base_speed
	if input.sprint:
		speed = sprint_speed
	
	var direction := (
		transform.basis * Vector3(input.move.x, 0, input.move.y)
		+ Vector3(0, updown, 0)
	).normalized()
	
	position += direction * speed;
