extends Node

@export
var spin_sprite: Sprite2D

func _ready() -> void:
	assert(spin_sprite)
	if OS.is_debug_build():
		print("DEBUG MODE")


func _process(delta: float) -> void:
	spin_sprite.rotate(delta * 2.0)
