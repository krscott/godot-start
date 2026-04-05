extends Node2D

const SENSITIVITY := 0.02

@export var use_y := false


func _physics_process(_delta: float) -> void:
	rotation = reinput.get_custom(name, rotation, 0.0)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not reinput.is_replaying():
		var ev: InputEventMouseMotion = event

		var dr: float
		if use_y:
			dr = ev.relative.y
		else:
			dr = ev.relative.x

		rotate(dr * SENSITIVITY)
