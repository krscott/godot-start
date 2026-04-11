extends Node

var _was_paused_last_frame := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _physics_process(_delta: float) -> void:
	if (
		not _was_paused_last_frame and
		Input.is_action_just_pressed("pause")
	):
		gamestate.paused_pub.state = true

	get_tree().paused = gamestate.paused_pub.state
	_was_paused_last_frame = gamestate.paused_pub.state


func _notification(what: int) -> void:
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			gamestate.paused_pub.state = true
