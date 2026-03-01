class_name ReplaySystem
extends Node

@export var player_input: PlayerInput
@export var save_state: SaveState
@export var system_dialog: SystemDialog

@onready var replay: Replay = $Replay


func run_from_file(filename: String) -> void:
	if OK == replay.load_from_file(filename):
		replay.start()


func _ready() -> void:
	assert(player_input)
	assert(save_state)
	assert(system_dialog)
	assert(replay)

	util.aok(replay.load_frame.connect(_replay_load_frame))
	util.aok(replay.request_frame.connect(_replay_save_frame))


func _physics_process(_delta: float) -> void:
	player_input.listening = not replay.is_active


func _replay_load_frame(frame: Dictionary) -> void:
	util.aok(GdSerde.deserialize_object(player_input, frame))
	if replay.is_active:
		player_input.listening = false
	else:
		print("REPLAY DONE")
		gamestate._pause() # TODO


func _replay_save_frame() -> void:
	replay.add_frame(GdSerde.serialize_object(player_input))


func _save_replay_and_quit() -> void:
	if replay.enabled:
		util.aok(replay.save_to_file("replay.dat"))

	await get_tree().process_frame
	get_tree().quit()


func _restart_replay() -> void:
	save_state.reset()
	replay.restart()


func _replay_open_dialog() -> void:
	var filename := await system_dialog.file_open_dialog("*.dat", "Replay File")
	if filename:
		var _err := replay.load_from_file(filename)
		_restart_replay()
		gamestate._unpause() # TODO
