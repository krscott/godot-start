extends Node

@onready var save_state: SaveState = %SaveState
@onready var stretch_filter: CanvasLayer = %StretchFilter
@onready var dither_filter: CanvasLayer = %DitherFilter
@onready var palette_filter: CanvasLayer = %PaletteFilter
@onready var dialogue_layer: DialogueLayer = %DialogueLayer
@onready var menu: Menu = %Menu
@onready var system_dialog: SystemDialog = %SystemDialog

# Public Methods


func sync_object_state(key: StringName, obj: Object) -> void:
	save_state.sync_object_state(key, obj)

# Interface Methods


func _ready() -> void:
	assert(save_state)
	#assert(pause_menu_system)
	assert(stretch_filter)
	assert(dither_filter)
	assert(palette_filter)
	assert(dialogue_layer)
	assert(menu)
	assert(system_dialog)

	util.printdbg("DEBUG BUILD")

	var args := OS.get_cmdline_user_args()
	if args:
		util.printdbg("CLI args: ", args)
		#_replay_system.run_from_file(args[0])

	util.a_ok(gamestate.dither_filter.turned_on.connect(dither_filter.show))
	util.a_ok(gamestate.dither_filter.turned_off.connect(dither_filter.hide))
	util.a_ok(gamestate.palette_filter.turned_on.connect(palette_filter.show))
	util.a_ok(gamestate.palette_filter.turned_off.connect(palette_filter.hide))


func _process(_delta: float) -> void:
	if not menu.visible:
		if Input.is_action_just_pressed("quick_save"):
			save_state.quicksave()
		elif Input.is_action_just_pressed("quick_load"):
			save_state.quickload()

# Private Methods
