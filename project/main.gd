extends Node
const gdserde_class := &"Main"
const gdserde_props := [&"freecam"]

@export
var freecam: FreeCam

var player_input := PlayerInput.new()

var quick_save := {}

func _ready() -> void:
	assert(freecam)
	if OS.is_debug_build():
		print("DEBUG MODE")
	
	util.mouse_capture()


func _physics_process(_delta: float) -> void:
	player_input.update_physics_from_input()
	freecam.apply_physics_input(player_input)
	
	GdSerde.serialize(player_input)
	GdSerde.serialize(freecam)


func _process(_delta: float) -> void:
	if player_input.quit:
		get_tree().quit()
	
	if player_input.mouse_captured:
		util.mouse_capture()
	else:
		util.mouse_show()
	
	freecam.apply_view_input(player_input)


func _input(event: InputEvent) -> void:
	player_input.update_view_from_event(event)
	
	match event.get_class():
		"InputEventKey", "InputEventMouseButton":
			if Input.is_action_just_pressed("quick_save"):
				quick_save = GdSerde.serialize(self)
				print(quick_save)
			elif Input.is_action_just_pressed("quick_load"):
				pass
