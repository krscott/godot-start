extends Node2D

@onready var replay_status_label: Label = %ReplayStatus
@onready var replay_size_label: Label = %ReplaySize
@onready var rng_label: Label = %RngLabel
@onready var buttons_container: Control = %ButtonsContainer


func _ready() -> void:
	assert(replay_status_label)
	assert(replay_size_label)
	assert(rng_label)
	assert(buttons_container)

	for btn: Button in buttons_container.get_children():
		reinput.connect_signal(btn, &"pressed")


func _physics_process(_delta: float) -> void:
	if reinput.is_replaying():
		replay_status_label.text = "REPLAY"
	else:
		replay_status_label.text = "LIVE"
	replay_size_label.text = util.human_readable_byte_count(reinput.size())

	if Input.is_action_just_pressed("replay_reload"):
		reinput.start()
		util.a_ok(get_tree().reload_current_scene())


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var ev: InputEventMouseButton = event
		if ev.button_index == MouseButton.MOUSE_BUTTON_LEFT and ev.pressed:
			reinput.event(ev, [&"button_index", &"pressed"])
			rng_label.text = str(reinput.rng().randi())
