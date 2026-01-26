extends Node
class_name World
const gdserde_class := &"World"
const gdserde_props := [&"freecam", &"box"]

@export var freecam: FreeCam
@export var box: Node3D

func _ready() -> void:
	assert(freecam)
	assert(box)

func apply_view_input(input: PlayerInput) -> void:
	freecam.apply_view_input(input)

func apply_physics_input(input: PlayerInput) -> void:
	freecam.apply_physics_input(input)
