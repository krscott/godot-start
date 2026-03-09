class_name GameState
extends Node

@onready var _save_state: SaveState = %SaveState
@onready var _pause_menu_system: PauseMenuSystem = %PauseMenuSystem
@onready var _replay_system: ReplaySystem = %ReplaySystem
@onready var player_input: PlayerInput = %PlayerInput
@onready var _sequence_builder: SequenceBuilder = %SequenceBuilder.sequence_builder

# Public Methods


func sync_object_state(key: StringName, obj: Object) -> void:
	_save_state.sync_object_state(key, obj)

# Interface Methods


func _ready() -> void:
	assert(_save_state)
	assert(_pause_menu_system)
	assert(_replay_system)
	assert(player_input)
	assert(_sequence_builder)

	util.printdbg("DEBUG BUILD")

	# Add function here!

	# Provider exposes RefCounted builder; node in tree so we can use %SequenceBuilder
	var _sequence := _sequence_builder.build_from_file("res://dialog_system/test_json.json")
	print(_sequence)

	sync_object_state(&"player_input", player_input)

	var args := OS.get_cmdline_user_args()
	if args:
		util.printdbg("CLI args: ", args)
		_replay_system.run_from_file(args[0])


func _process(_delta: float) -> void:
	if not _pause_menu_system.is_menu_open():
		if Input.is_action_just_pressed("quick_save"):
			_save_state.quicksave()
		elif Input.is_action_just_pressed("quick_load"):
			_save_state.quickload()
		elif Input.is_action_just_pressed("quit"):
			if OS.has_feature("pc"):
				_replay_system._save_replay_and_quit()
			else:
				_pause_menu_system.pause()
		elif Input.is_action_just_pressed("ui_cancel"):
			_pause_menu_system.pause()

# Private Methods
