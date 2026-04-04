extends Node2D

const SENSITIVITY := 0.02

@export var use_y := false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		reinput.event(event, [&"relative"])

		var ev: InputEventMouseMotion = event

		var dr: float
		if use_y:
			dr = ev.relative.y
		else:
			dr = ev.relative.x

		rotate(dr * SENSITIVITY)
