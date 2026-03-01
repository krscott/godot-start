class_name GameState
extends Node

@onready var save_state: SaveState = %SaveState
@onready var pause_menu_system: PauseMenuSystem = %PauseMenuSystem
@onready var replay_system: ReplaySystem = %ReplaySystem
@onready var player_input: PlayerInput = %PlayerInput
@onready var menu: Menu = %Menu
@onready var system_dialog: SystemDialog = %SystemDialog


# Public Methods

func sync_object_state(key: StringName, obj: Object) -> void:
	save_state.sync_object_state(key, obj)


# Interface Methods

func _ready() -> void:
	assert(save_state)
	assert(pause_menu_system)
	assert(replay_system)
	assert(player_input)
	assert(menu)
	assert(system_dialog)

	util.printdbg("DEBUG BUILD")

	sync_object_state(&"player_input", player_input)

	var args := OS.get_cmdline_user_args()
	if args:
		util.printdbg("CLI args: ", args)
		replay_system.run_from_file(args[0])


func _process(_delta: float) -> void:
	if not menu.visible:
		if Input.is_action_just_pressed("quick_save"):
			save_state.quicksave()
		elif Input.is_action_just_pressed("quick_load"):
			save_state.quickload()
		elif Input.is_action_just_pressed("quit"):
			if OS.has_feature("pc"):
				replay_system._save_replay_and_quit()
			else:
				pause_menu_system.pause()
		elif Input.is_action_just_pressed("ui_cancel"):
			pause_menu_system.pause()


# Private Methods
