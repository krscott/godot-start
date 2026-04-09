class_name PauseHandler
extends Node

var _is_paused := false
var _was_paused_last_frame := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	util.a_ok(signalbus.pause_requested.connect(_pause_requested))
	util.a_ok(signalbus.unpause_requested.connect(_unpause_requested))

	if gamestate.pause_on_statup:
		_pause_requested()


func _physics_process(_delta: float) -> void:
	if (
		not _is_paused and
		not _was_paused_last_frame and
		Input.is_action_just_pressed("pause")
	):
		_pause_requested()

	if _is_paused != get_tree().paused:
		get_tree().paused = _is_paused
		gamestate.game_paused.set_state(_is_paused)

	_was_paused_last_frame = _is_paused


func _notification(what: int) -> void:
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			signalbus.pause_requested.emit()


func _pause_requested() -> void:
	_is_paused = true


func _unpause_requested() -> void:
	_is_paused = false
