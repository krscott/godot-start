## For changing Overlay settings for only a single level.
## This is so demo levels can be independent--you'll likely want to remove it
## after initializing the template and just change Overlay defaults directly.
class_name LevelConfig
extends Node

@export var record_replay := false
@export var mouse_capture := false
@export var skip_main_menu := false
@export var stretch_filter := false


func _ready() -> void:
	if record_replay and not reinput.is_replaying():
		reinput.record()

	#overlay.pause_menu_system.capture_mouse = mouse_capture
	#overlay.pause_menu_system.show_on_start = not skip_main_menu
	overlay.stretch_filter.visible = stretch_filter

	queue_free()
