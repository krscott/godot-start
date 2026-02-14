class_name GameState
extends Node


@onready var save_state: SaveState = %SaveState
@onready var pausing: Pausing = %Pausing
@onready var replay: Replay = %Replay
@onready var player_input: PlayerInput = %PlayerInput
@onready var menu: Menu = %Menu
@onready var system_dialog: SystemDialog = %SystemDialog
@onready var palette_filter: ColorRect = %PaletteFilter
@onready var dither_filter: ColorRect = %DitherFilter


# Public Methods

func sync_object_state(key: StringName, obj: Object) -> void:
	save_state.sync_object_state(key, obj)


# Interface Methods

func _ready() -> void:
	assert(save_state)
	assert(pausing)
	assert(replay)
	assert(player_input)
	assert(menu)
	assert(system_dialog)
	assert(palette_filter)
	assert(dither_filter)

	util.printdbg("DEBUG BUILD")

	sync_object_state(&"player_input", player_input)

	util.aok(replay.load_frame.connect(_replay_load_frame))
	util.aok(replay.request_frame.connect(_replay_save_frame))

	var args := OS.get_cmdline_user_args()
	if args:
		util.printdbg("CLI args: ", args)
		if OK == replay.load_from_file(args[0]):
			replay.start()

	_unpause()
	
	# NOTE: GameState node is the first child of the tree root.
	#       i.e., this node is visited FIRST, before any level-specific logic.
	#       We need to call-deferred if we want to run something after.
	call_deferred(&"_build_menu")


func _physics_process(_delta: float) -> void:
	player_input.listening = not replay.is_active


func _process(_delta: float) -> void:
	if not menu.visible:
		if Input.is_action_just_pressed("quick_save"):
			save_state.quicksave()
		elif Input.is_action_just_pressed("quick_load"):
			save_state.quickload()
		elif Input.is_action_just_pressed("quit"):
			_save_replay_and_quit()
		elif Input.is_action_just_pressed("ui_cancel"):
			_pause()


# Private Methods


func _replay_load_frame(frame: Dictionary) -> void:
	util.aok(GdSerde.deserialize_object(player_input, frame))
	if replay.is_active:
		player_input.listening = false
	else:
		print("REPLAY DONE")
		_pause()


func _replay_save_frame() -> void:
	replay.add_frame(GdSerde.serialize_object(player_input))


func _save_replay_and_quit() -> void:
	if replay.enabled:
		util.aok(replay.save_to_file("replay.dat"))

	await get_tree().process_frame
	get_tree().quit()


func _restart_replay() -> void:
	save_state.reset()
	replay.restart()


func _replay_open_dialog() -> void:
	var filename := await system_dialog.file_open_dialog("*.dat", "Replay File")
	if filename:
		var _err := replay.load_from_file(filename)
		_restart_replay()
		_unpause()


func _unpause() -> void:
	pausing.unpause()
	menu.hide()
	util.set_mouse_captured(true)


func _pause() -> void:
	pausing.pause()
	menu.show()
	util.set_mouse_captured(false)


func _save_game_dialog() -> void:
	var filename := await system_dialog.file_save_dialog("*.sav", "Save File")
	if filename:
		util.aok(save_state.save_to_file(filename))


func _load_game_dialog() -> void:
	var filename := await system_dialog.file_open_dialog("*.sav", "Save File")
	if filename:
		var _err := save_state.load_from_file(filename)


func _build_menu() -> void:
	menu.build([
		Menu.button("Continue", _unpause)
			.action("ui_cancel")
			.focus(),
		Menu.button("Save Game", _save_game_dialog),
		Menu.button("Load Game", _load_game_dialog),
		Menu.button("Load Replay", _replay_open_dialog),
		Menu.checkbox("Palette Filter", palette_filter.set_visible)
			.toggled(palette_filter.visible),
		Menu.checkbox("Dither Filter", dither_filter.set_visible)
			.toggled(dither_filter.visible),
		Menu.button("Quit", _save_replay_and_quit),
	])
