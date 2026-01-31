extends Node
const gdserde_class := &"Main"
const gdserde_props := [&"world", &"player_input"]

@export var world: World
@export var menu: Menu

var skip_next_mouse_move := true
var mouse_captured := true
var player_input := PlayerInput.new()
var replay := Replay.new()
var quick_save := {}
var quick_save_zero := {}

func _ready() -> void:
	assert(world)
	assert(menu)
	if OS.is_debug_build():
		print("DEBUG MODE")
	
	build_menu()
	
	quick_save_zero = GdSerde.serialize(self)
	quick_save = quick_save_zero

	var args := OS.get_cmdline_user_args()
	print(args)
	if args:
		if OK == replay.load_from_file(args[0]):
			print("REPLAY")
			replay.start()


func _physics_process(_delta: float) -> void:
	if get_tree().paused:
		return
		
	if replay.is_active:
		var err := GdSerde.deserialize_object(player_input, replay.next())
		assert(not err, error_string(err))
		if not replay.is_active:
			print("REPLAY DONE")
			pause()
	else:
		player_input.update_physics_from_input()
		replay.add_frame(GdSerde.serialize_object(player_input))

	world.apply_physics_input(player_input)


func _process(_delta: float) -> void:
	if mouse_captured:
		util.mouse_capture()
	else:
		util.mouse_show()

	if not get_tree().paused:
		world.apply_view_input(player_input)


func _input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	
	var err := OK
	match event.get_class():
		"InputEventMouseMotion":
			if skip_next_mouse_move:
				skip_next_mouse_move = false
			elif mouse_captured:
				player_input.update_view_from_event(event)
		"InputEventKey", "InputEventMouseButton":
			if Input.is_action_just_pressed("quick_save"):
				quick_save = GdSerde.serialize(self)
				print(JSON.stringify(quick_save))
			elif Input.is_action_just_pressed("quick_load"):
				err = GdSerde.deserialize_object(self, quick_save)
				assert(not err, error_string(err))
			elif Input.is_action_just_pressed("load_replay"):
				replay_open_dialog()
			elif Input.is_action_just_pressed("quit"):
				save_replay_and_quit()
			elif Input.is_action_just_pressed("toggle_mouse"):
				mouse_captured = not mouse_captured
				if mouse_captured:
					skip_next_mouse_move = true
			elif Input.is_action_just_pressed("ui_cancel"):
				pause()
			else:
				player_input.update_view_from_event(event)


func save_replay_and_quit() -> void:
	var err := replay.save_to_file("replay.dat")
	assert(not err, error_string(err))
	get_tree().quit()


func restart_replay() -> void:
	load_savedata(quick_save_zero)
	replay.restart()


func load_savedata(data: Dictionary) -> void:
	var err := GdSerde.deserialize_object(self, data)
	assert(not err, error_string(err))


func file_open_dialog(
	filter: String = "",
	description: String = ""
) -> String:
	var original_mouse_captured := mouse_captured
	mouse_captured = false
	
	var filename := await Popupper.file_open_dialog(
		self, filter, description
	)
	
	mouse_captured = original_mouse_captured
	return filename

func replay_open_dialog() -> void:
	var filename := await file_open_dialog("*.dat", "Replay File")
	if filename:
		var err := replay.load_from_file(filename)
		assert(not err, error_string(err))
		restart_replay()
		unpause()

func set_paused(paused: bool) -> void:
	# Align pause state to frame
	await get_tree().process_frame
	
	menu.visible = paused
	mouse_captured = not paused
	get_tree().paused = paused
	if paused:
		print("PAUSED")
	else:
		print("UNPAUSED")

func unpause() -> void:
	set_paused(false)

func pause() -> void:
	set_paused(true)

func build_menu() -> void:
	menu.build([
		Menu.btn("Continue", unpause, "ui_cancel"),
		Menu.btn("Load Replay", replay_open_dialog),
		Menu.btn("Quit", save_replay_and_quit),
	])
