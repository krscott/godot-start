class_name AutoloadOverlay
extends Node

@export var _test_cycle_scenes: Array[PackedScene] = []

@onready var save_state: SaveState = %SaveState
@onready var _dither_filter: CanvasLayer = %DitherFilter
@onready var _palette_filter: CanvasLayer = %PaletteFilter
@onready var dialogue_layer: DialogueLayer = %DialogueLayer
@onready var screen_fade: ScreenFade = %ScreenFade
@onready var system_dialog: SystemDialog = %SystemDialog

# Public Methods


func sync_object_state(key: StringName, obj: Object) -> void:
	save_state.sync_object_state(key, obj)

# Interface Methods


func _ready() -> void:
	assert(save_state)
	assert(_dither_filter)
	assert(_palette_filter)
	assert(dialogue_layer)
	assert(screen_fade)
	assert(system_dialog)
	assert(_test_cycle_scenes, "add some scenes to _test_cycle_scenes")

	util.printdbg("DEBUG BUILD")

	var args := OS.get_cmdline_user_args()
	if args:
		util.printdbg("CLI args: ", args)
		if "--test-cycle" in args:
			call_deferred(&"_test_cycle")

		#_replay_system.run_from_file(args[0])

	util.a_ok(gamestate.dither_filter_pub.changed.connect(_dither_filter.set_visible))
	util.a_ok(gamestate.palette_filter_pub.changed.connect(_palette_filter.set_visible))

	util.a_ok(gamestate.paused_pub.turned_on.connect(gamestate.menu_open_pub.turn_on))
	util.a_ok(gamestate.menu_open_pub.turned_off.connect(gamestate.paused_pub.turn_off))


func _process(_delta: float) -> void:
	if not gamestate.menu_open_pub.state:
		if Input.is_action_just_pressed("quick_save"):
			save_state.quicksave()
		elif Input.is_action_just_pressed("quick_load"):
			save_state.quickload()

# Private Methods


func _test_cycle() -> void:
	for scene in _test_cycle_scenes:
		print("Testing scene: ", scene)
		util.a_ok(get_tree().change_scene_to_packed(scene))
		await get_tree().create_timer(1.0).timeout

	print("Test cycle complete")
	get_tree().quit()
