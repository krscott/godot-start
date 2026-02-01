extends Node


@onready var pausing: Pausing = %Pausing
@onready var replay: Replay = %Replay
@onready var player_input: PlayerInput = %PlayerInput
@onready var world: World = %World
@onready var menu: Menu = %Menu
@onready var system_dialog: SystemDialog = %SystemDialog


var quick_save := {}
var quick_save_zero := {}


func _ready() -> void:
	assert(pausing)
	assert(replay)
	assert(player_input)
	assert(world)
	assert(menu)
	assert(system_dialog)

	if OS.is_debug_build():
		print("DEBUG MODE")

	util.aok(replay.load_frame.connect(_replay_load_frame))
	util.aok(replay.request_frame.connect(_replay_save_frame))

	build_menu()

	quick_save_zero = _save_savedata()
	quick_save = quick_save_zero

	var args := OS.get_cmdline_user_args()
	print(args)
	if args:
		if OK == replay.load_from_file(args[0]):
			replay.start()

	unpause()


func _process(_delta: float) -> void:
	if not menu.visible:
		if Input.is_action_just_pressed("quick_save"):
			quick_save = _save_savedata()
		elif Input.is_action_just_pressed("quick_load"):
			_load_savedata(quick_save)
		elif Input.is_action_just_pressed("quit"):
			_save_replay_and_quit()
		elif Input.is_action_just_pressed("ui_cancel"):
			pause()


func _replay_load_frame(frame: Dictionary) -> void:
	util.aok(GdSerde.deserialize_object(player_input, frame))
	if replay.is_active:
		player_input.skip_frame = true
	else:
		print("REPLAY DONE")
		pause()


func _replay_save_frame() -> void:
	replay.add_frame(GdSerde.serialize_object(player_input))


func _save_replay_and_quit() -> void:
	if replay.enabled:
		util.aok(replay.save_to_file("replay.dat"))

	await get_tree().process_frame
	get_tree().quit()


func _restart_replay() -> void:
	_load_savedata(quick_save_zero)
	replay.restart()


func _load_savedata(data: Dictionary) -> void:
	util.aok(GdSerde.deserialize_object(world, data))


func _save_savedata() -> Dictionary:
	var savedata := GdSerde.serialize_object(world)
	print(JSON.stringify(savedata))
	return savedata


func replay_open_dialog() -> void:
	var filename := await system_dialog.file_open_dialog("*.dat", "Replay File")
	if filename:
		var err := replay.load_from_file(filename)
		assert(not err, error_string(err))
		_restart_replay()
		unpause()


func unpause() -> void:
	pausing.unpause()
	menu.hide()
	util.set_mouse_captured(true)


func pause() -> void:
	pausing.pause()
	menu.show()
	util.set_mouse_captured(false)


func build_menu() -> void:
	menu.build([
		Menu.btn("Continue", unpause, "ui_cancel"),
		Menu.btn("Load Replay", replay_open_dialog),
		Menu.btn("Quit", _save_replay_and_quit),
	])
