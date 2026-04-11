class_name CaptureMouse
extends Node

@export var enabled := true


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

	util.a_ok(overlay.paused_pub.changed.connect(_game_pause_changed))
	util.a_ok(overlay.menu_open_pub.changed.connect(_game_pause_changed))
	_game_pause_changed()


func _game_pause_changed(..._args: Array) -> void:
	var cap := enabled and not overlay.paused_pub.state and not overlay.menu_open_pub.state
	util.set_mouse_captured(cap)
