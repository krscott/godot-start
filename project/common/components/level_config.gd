## For changing Overlay settings for only a single level.
## This is so demo levels can be independent--you'll likely want to remove it
## after initializing the template and just change Overlay defaults directly.
class_name LevelConfig
extends Node

@export var record_replay := false
@export var stretch_filter := false
@export var show_main_menu := false
@export var pause_on_start := false


func _ready() -> void:
	if record_replay and not reinput.is_replaying():
		reinput.record()

	if stretch_filter:
		overlay.stretch_fitler_pub.state = true

	if show_main_menu:
		overlay.menu_open_pub.state = true

	if pause_on_start:
		overlay.paused_pub.state = true

	queue_free()
