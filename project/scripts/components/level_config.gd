class_name LevelConfig
extends Node


@export var mouse_capture := false
@export var stretch_filter := false


func _ready() -> void:
	gamestate.pause_menu_system.capture_mouse = mouse_capture
	gamestate.stretch_filter.visible = stretch_filter

	queue_free()
