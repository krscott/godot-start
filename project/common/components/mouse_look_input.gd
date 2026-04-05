class_name MouseLookInput
extends Node

signal angles_changed(angles: Vector2)

@export var enabled := true
@export var sensitivity := 0.2
@export var min_angle := -90.0
@export var max_angle := 90

var angles := Vector2.ZERO


func _input(event: InputEvent) -> void:
	if enabled and event is InputEventMouseMotion and reinput.event(event, [&"relative"]):
		var ev: InputEventMouseMotion = event
		var prev := angles
		angles.y -= (ev.relative.x * sensitivity)
		angles.x -= (ev.relative.y * sensitivity)
		angles.x = clamp(angles.x, min_angle, max_angle)
		if prev != angles:
			angles_changed.emit(angles)
