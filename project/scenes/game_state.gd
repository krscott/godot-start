class_name GameState
extends Node


signal savedata_saving
signal savedata_loaded


@onready var pausing: Pausing = %Pausing
@onready var replay: Replay = %Replay
@onready var player_input: PlayerInput = %PlayerInput
@onready var menu: Menu = %Menu
@onready var system_dialog: SystemDialog = %SystemDialog
@onready var palette_filter: ColorRect = %PaletteFilter


## Dictionary[StringName, Dictionary]
var _savedata_state := {}
## Dictionary[StringName, Object]
var _savedata_refs := {}

## Player quick save
var _quick_save := {}
## Save of initial game state
var _quick_save_zero := {}


# Public Methods

func update_state(key: StringName, obj: Object) -> void:
	_savedata_state[key] = GdSerde.serialize_object(obj)


func load_state(key: StringName, obj: Object) -> void:
	if _savedata_state.has(key):
		var dict: Dictionary = _savedata_state[key]
		util.aok(GdSerde.deserialize_object(obj, dict))


func sync_state(key: StringName, obj: Object) -> void:
	print("Sync state: ", key)

	load_state(key, obj)
	if OS.is_debug_build():
		# Debug-only check for serde errors
		var dict := GdSerde.serialize_object(obj)
		util.aok(GdSerde.deserialize_object(obj, dict))

	_savedata_refs[key] = obj


# Interface Methods

func _ready() -> void:
	assert(pausing)
	assert(replay)
	assert(player_input)
	assert(menu)
	assert(system_dialog)
	assert(palette_filter)

	# NOTE: GameState node is the first child of the current level's node.
	#       i.e., this node is visited FIRST.
	#       We need to call-deferred if we want to run something after root.
	call_deferred(&"_root_ready")

	if OS.is_debug_build():
		print("DEBUG MODE")

	sync_state(&"player_input", player_input)

	util.aok(replay.load_frame.connect(_replay_load_frame))
	util.aok(replay.request_frame.connect(_replay_save_frame))

	var args := OS.get_cmdline_user_args()
	if args:
		print("CLI args: ", args)
		if OK == replay.load_from_file(args[0]):
			replay.start()

	_unpause()


func _physics_process(_delta: float) -> void:
	player_input.listening = not replay.is_active


# Private Methods

func _root_ready() -> void:
	_quick_save_zero = _serialize_savedata()
	_quick_save = _quick_save_zero

	_build_menu()


func _process(_delta: float) -> void:
	if not menu.visible:
		if Input.is_action_just_pressed("quick_save"):
			_quick_save = _serialize_savedata()
		elif Input.is_action_just_pressed("quick_load"):
			_deserialize_savedata(_quick_save)
		elif Input.is_action_just_pressed("quit"):
			_save_replay_and_quit()
		elif Input.is_action_just_pressed("ui_cancel"):
			_pause()


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
	_deserialize_savedata(_quick_save_zero)
	replay.restart()


func _deserialize_savedata(data: Dictionary) -> void:
	_savedata_state = data
	for k: StringName in _savedata_refs:
		if is_instance_valid(_savedata_refs[k]):
			var obj: Object = _savedata_refs[k]
			load_state(k, obj)
		else:
			util.expect_true(_savedata_refs.erase(k))

	print("Loaded savedata")
	print(JSON.stringify(_savedata_state))
	savedata_loaded.emit()


func _serialize_savedata() -> Dictionary:
	savedata_saving.emit()

	for k: StringName in _savedata_refs:
		if is_instance_valid(_savedata_refs[k]):
			var obj: Object = _savedata_refs[k]
			update_state(k, obj)
		else:
			util.expect_true(_savedata_refs.erase(k))

	print("Saved savedata")
	print(JSON.stringify(_savedata_state))
	return _savedata_state


func _replay_open_dialog() -> void:
	var filename := await system_dialog.file_open_dialog("*.dat", "Replay File")
	if filename:
		var err := replay.load_from_file(filename)
		assert(not err, error_string(err))
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


func _toggle_palette_filter(on: bool) -> void:
	palette_filter.visible = on


func _quack() -> void:
	print("QUACK!")


func _build_menu() -> void:
	menu.build([
		Menu.button("DEBUG MODE", _quack)
			.debug_only(),
		Menu.button("Continue", _unpause)
			.action("ui_cancel")
			.focus(),
		Menu.button("Load Replay", _replay_open_dialog),
		Menu.checkbox("Palette Filter", _toggle_palette_filter)
			.toggled(palette_filter.visible),
		Menu.button("Quit", _save_replay_and_quit),
	])
