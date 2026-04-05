extends Node2D

@onready var replay_status_label: Label = %ReplayStatus
@onready var replay_size_label: Label = %ReplaySize
@onready var rng_label: Label = %RngLabel

var _mouse_pressed := false


func _ready() -> void:
	assert(replay_status_label)
	assert(replay_size_label)
	assert(rng_label)


func _physics_process(_delta: float) -> void:
	if reinput.is_replaying():
		replay_status_label.text = "REPLAY"
	else:
		replay_status_label.text = "LIVE"
	replay_size_label.text = util.human_readable_byte_count(reinput.size())

	if Input.is_action_just_pressed("replay_reload"):
		reinput.rewind_and_play()
		util.a_ok(get_tree().reload_current_scene())

	if reinput.get_custom(&"pick_random_number", _mouse_pressed, false):
		_mouse_pressed = false
		var _throwaway: int = reinput.rng().randi() # skip one
		rng_label.text = str(reinput.rng().randi())


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var ev: InputEventMouseButton = event
		if ev.button_index == MouseButton.MOUSE_BUTTON_LEFT and ev.pressed:
			_mouse_pressed = true
