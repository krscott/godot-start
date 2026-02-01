extends Node
class_name World
const gdserde_class := &"World"
const gdserde_props := [
	&"box",
	&"freecam",
]

@export var box: Node3D
@export var freecam: FreeCam

@onready var player_input: PlayerInput = %PlayerInput

func _ready() -> void:
	assert(freecam)
	assert(box)
	assert(player_input)

	freecam.maybe_input = player_input
