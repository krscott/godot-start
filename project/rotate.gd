extends Node3D
const gdserde_class := &"Rotate"
const gdserde_props := [&"transform"]

@export
var speed := 1.0


func _physics_process(delta: float) -> void:
	rotate(Vector3.UP, speed * delta)
