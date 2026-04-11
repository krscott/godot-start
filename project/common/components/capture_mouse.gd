class_name CaptureMouse
extends Node

@export var enabled := true


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

	util.a_ok(gamestate.paused_pub.changed.connect(_game_pause_changed))
	util.a_ok(gamestate.menu_open_pub.changed.connect(_game_pause_changed))
	_game_pause_changed()


func _game_pause_changed(..._args: Array) -> void:
	var cap: bool = enabled and not gamestate.paused_pub.state and not gamestate.menu_open_pub.state
	util.set_mouse_captured(cap)
