extends Node

@onready var save_state: SaveState = %SaveState
@onready var _dither_filter: CanvasLayer = %DitherFilter
@onready var _palette_filter: CanvasLayer = %PaletteFilter
@onready var dialogue_layer: DialogueLayer = %DialogueLayer
@onready var system_dialog: SystemDialog = %SystemDialog

# Pub/Sub state

var stretch_fitler_pub := pubsub.Bool.new()
var palette_filter_pub := pubsub.Bool.new()
var dither_filter_pub := pubsub.Bool.new()

var paused_pub := pubsub.Bool.new()
var menu_open_pub := pubsub.Bool.new()

# Public Methods


func sync_object_state(key: StringName, obj: Object) -> void:
	save_state.sync_object_state(key, obj)

# Interface Methods


func _ready() -> void:
	assert(save_state)
	#assert(pause_menu_system)
	assert(_dither_filter)
	assert(_palette_filter)
	assert(dialogue_layer)
	assert(system_dialog)

	util.printdbg("DEBUG BUILD")

	var args := OS.get_cmdline_user_args()
	if args:
		util.printdbg("CLI args: ", args)
		#_replay_system.run_from_file(args[0])

	util.a_ok(dither_filter_pub.changed.connect(_dither_filter.set_visible))
	util.a_ok(palette_filter_pub.changed.connect(_palette_filter.set_visible))

	util.a_ok(paused_pub.turned_on.connect(menu_open_pub.turn_on))
	util.a_ok(menu_open_pub.turned_off.connect(paused_pub.turn_off))


func _process(_delta: float) -> void:
	if not menu_open_pub.state:
		if Input.is_action_just_pressed("quick_save"):
			save_state.quicksave()
		elif Input.is_action_just_pressed("quick_load"):
			save_state.quickload()

# Private Methods
