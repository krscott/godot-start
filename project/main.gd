extends Node
const gdserde_class := &"Main"
const gdserde_props := [&"world", &"player_input"]

@export var world: World

var skip_next_mouse_move := true
var mouse_captured := true
var player_input := PlayerInput.new()

var quick_save := {}

func _ready() -> void:
	assert(world)

	if OS.is_debug_build():
		print("DEBUG MODE")

	util.mouse_capture()


func _physics_process(_delta: float) -> void:
	player_input.update_physics_from_input()
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
				print(quick_save)
			elif Input.is_action_just_pressed("quick_load"):
				var res := GdSerde.deserialize(self, quick_save)
				assert(not res.err)
			elif Input.is_action_just_pressed("quit"):
				get_tree().quit()
			elif Input.is_action_just_pressed("toggle_mouse"):
				mouse_captured = not mouse_captured
				if mouse_captured:
					skip_next_mouse_move = true
			else:
				player_input.update_view_from_event(event)
