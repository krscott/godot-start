extends Node

@export
var spin_sprite: Sprite2D

func _ready() -> void:
	assert(spin_sprite)


func _process(delta: float) -> void:
	spin_sprite.rotate(delta * 2.0)
