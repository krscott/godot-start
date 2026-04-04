extends Node2D

@onready var replay_status_label: Label = %ReplayStatus
@onready var replay_size_label: Label = %ReplaySize


func _ready() -> void:
	assert(replay_status_label)
	assert(replay_size_label)


func _physics_process(_delta: float) -> void:
	if reinput.is_replaying():
		replay_status_label.text = "REPLAY"
	else:
		replay_status_label.text = "LIVE"
	replay_size_label.text = util.human_readable_byte_count(reinput.size())

	if Input.is_action_just_pressed("replay_reload"):
		reinput.start()
		util.a_ok(get_tree().reload_current_scene())
