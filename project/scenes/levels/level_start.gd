extends Node

const gdserde_class := &"World"
const gdserde_props := [
	&"box",
	&"freecam",
]

@export var box: Node3D
@export var freecam: FreeCam

func _ready() -> void:
	assert(freecam)
	assert(box)
	
	gamestate.sync_state(&"level_start", self)

	freecam.maybe_input = gamestate.player_input
