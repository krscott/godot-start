extends Node
const gdserde_class := &"Main"
const gdserde_props := [&"world", &"player_input"]

@export var world: World

var skip_next_mouse_move := true
var mouse_captured := true
var player_input := PlayerInput.new()

var quick_save := {}

var replay_active := false
var replay_frame := 0
var replay := []

func _ready() -> void:
	assert(world)
	if OS.is_debug_build():
		print("DEBUG MODE")
	quick_save = GdSerde.serialize(self)

	var args := OS.get_cmdline_user_args()
	print(args)
	if args:
		print("Loading replay: ", args[0])
		var replay_data := FileAccess.get_file_as_bytes(args[0])
		replay = bytes_to_var(replay_data)
		replay_active = true


func save_replay_and_quit() -> void:
	var f := FileAccess.open("replay.dat", FileAccess.ModeFlags.WRITE)
	var ok := f.store_buffer(var_to_bytes(replay))
	assert(ok)
	get_tree().quit()


func _physics_process(_delta: float) -> void:
	if replay_frame >= replay.size():
		replay_active = false
	if replay_active:
		var res := GdSerde.deserialize(player_input, replay[replay_frame])
		assert(not res.err)
		replay_frame += 1
	else:
		player_input.update_physics_from_input()
		replay.push_back(GdSerde.serialize(player_input))

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
				var res := GdSerde.deserialize(self, quick_save)
				assert(not res.err)
			elif Input.is_action_just_pressed("quit"):
				save_replay_and_quit()
			elif Input.is_action_just_pressed("toggle_mouse"):
				mouse_captured = not mouse_captured
				if mouse_captured:
					skip_next_mouse_move = true
			else:
				player_input.update_view_from_event(event)
