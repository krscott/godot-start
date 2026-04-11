class_name FreeCam
extends Camera3D

const type_name := &"FreeCam"


static func type_def() -> Dictionary:
	return { &"transform": null }


@export var enabled := true
@export var base_speed := 5.0
@export var sprint_speed := 20.0
@export var sensitivity := 0.2
@export var min_angle := -90.0
@export var max_angle := 90


func _is_active() -> bool:
	return enabled and not overlay.menu_open_pub.state


func _physics_process(delta: float) -> void:
	# TODO: Remove
	if Input.is_action_just_pressed("replay_reload"):
		reinput.rewind_and_play()
		util.a_ok(get_tree().reload_current_scene())

	if _is_active():
		# Explicitly typed due to https://github.com/godotengine/godot/issues/114422
		var updown: float = reinput.get_axis("crouch", "jump")

		var distance := base_speed * delta
		if reinput.is_action_pressed("sprint"):
			distance = sprint_speed * delta

		var move: Vector2 = reinput.get_vector(
			"move_left",
			"move_right",
			"move_forward",
			"move_backward",
		)

		rotation_degrees = reinput.get_custom(&"free_cam_rotation", rotation_degrees, Vector3.ZERO)

		var direction := (
			transform.basis * Vector3(move.x, 0.0, move.y) + Vector3(0.0, updown, 0.0)
		).normalized()

		position += direction * distance


func _input(event: InputEvent) -> void:
	if _is_active() and not reinput.is_replaying() and event is InputEventMouseMotion:
		var ev: InputEventMouseMotion = event
		var look := Vector2(rotation_degrees.x, rotation_degrees.y)

		look.y -= (ev.relative.x * sensitivity)
		look.x -= (ev.relative.y * sensitivity)
		look.x = clamp(look.x, min_angle, max_angle)

		rotation_degrees.x = look.x
		rotation_degrees.y = look.y
