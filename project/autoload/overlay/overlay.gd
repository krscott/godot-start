extends Node

@onready var _save_state: SaveState = %SaveState
@onready var pause_menu_system: PauseMenuSystem = %PauseMenuSystem
@onready var stretch_filter: CanvasLayer = %StretchFilter
@onready var dialogue_layer: DialogueLayer = %DialogueLayer
@onready var screen_fade: ScreenFade = %ScreenFade

# Public Methods


func sync_object_state(key: StringName, obj: Object) -> void:
	_save_state.sync_object_state(key, obj)

# Interface Methods


func _ready() -> void:
	assert(_save_state)
	assert(pause_menu_system)
	assert(stretch_filter)
	assert(dialogue_layer)
	assert(screen_fade)

	util.printdbg("DEBUG BUILD")

	var args := OS.get_cmdline_user_args()
	if args:
		util.printdbg("CLI args: ", args)
		#_replay_system.run_from_file(args[0])


func _process(_delta: float) -> void:
	if not pause_menu_system.is_menu_open():
		if Input.is_action_just_pressed("quick_save"):
			_save_state.quicksave()
		elif Input.is_action_just_pressed("quick_load"):
			_save_state.quickload()
		elif Input.is_action_just_pressed("quit"):
			if OS.has_feature("pc"):
				pass
				#_replay_system._save_replay_and_quit()
			else:
				pause_menu_system.pause()
		elif Input.is_action_just_pressed("ui_cancel"):
			pause_menu_system.pause()

# Private Methods
