extends Node
const gdserde_class := &"Main"
const gdserde_props := [&"world", &"player_input"]

@export var world: World

var skip_next_mouse_move := true
var mouse_captured := true
var player_input := PlayerInput.new()
var replay := Replay.new()
var quick_save := {}


func _ready() -> void:
	assert(world)
	if OS.is_debug_build():
		print("DEBUG MODE")
	quick_save = GdSerde.serialize(self)

	var args := OS.get_cmdline_user_args()
	print(args)
	if args:
		if OK == replay.load_from_file(args[0]):
			print("REPLAY")
			replay.start()


func save_replay_and_quit() -> void:
	var err := replay.save_to_file("replay.dat")
	assert(not err)
	get_tree().quit()


func _physics_process(_delta: float) -> void:
	if replay.is_active:
		var err := GdSerde.deserialize_object(player_input, replay.next())
		assert(not err)
		if not replay.is_active:
			print("REPLAY DONE")
	else:
		player_input.update_physics_from_input()
		replay.add_frame(GdSerde.serialize_object(player_input))

	world.apply_physics_input(player_input)


func _process(_delta: float) -> void:
	if mouse_captured:
		util.mouse_capture()
	else:
		util.mouse_show()

	world.apply_view_input(player_input)


func _input(event: InputEvent) -> void:
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
				var err := GdSerde.deserialize_object(self, quick_save)
				assert(not err)
			elif Input.is_action_just_pressed("load_replay"):
				mouse_captured = false
				var filename := await Popupper.open_file_dialog(self, "*.dat", "Replay File")
				mouse_captured = true
				print(filename)
			elif Input.is_action_just_pressed("quit"):
				save_replay_and_quit()
			elif Input.is_action_just_pressed("toggle_mouse"):
				mouse_captured = not mouse_captured
				if mouse_captured:
					skip_next_mouse_move = true
			else:
				player_input.update_view_from_event(event)
