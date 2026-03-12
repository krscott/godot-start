class_name EnableStretchFilter
extends Node

func _ready() -> void:
	gamestate.stretch_filter.show()
	queue_free()
