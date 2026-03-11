class_name GameState
extends Node

@onready var _save_state: SaveState = %SaveState
@onready var _pause_menu_system: PauseMenuSystem = %PauseMenuSystem
@onready var _replay_system: ReplaySystem = %ReplaySystem
@onready var player_input: PlayerInput = %PlayerInput
@onready var _sequence_builder: SequenceBuilder = %SequenceBuilder.sequence_builder

# Public Methods


func sync_object_state(key: StringName, obj: Object) -> void:
	_save_state.sync_object_state(key, obj)

# Interface Methods


func _ready() -> void:
	print("Ready!")
	assert(_save_state)
	assert(_pause_menu_system)
	assert(_replay_system)
	assert(player_input)
	assert(_sequence_builder)

	util.printdbg("DEBUG BUILD")

	sync_object_state(&"player_input", player_input)

	var args := OS.get_cmdline_user_args()
	if args:
		util.printdbg("CLI args: ", args)
		_replay_system.run_from_file(args[0])


func _process(_delta: float) -> void:
	if not _pause_menu_system.is_menu_open():
		if Input.is_action_just_pressed("quick_save"):
			_save_state.quicksave()
		elif Input.is_action_just_pressed("quick_load"):
			_save_state.quickload()
		elif Input.is_action_just_pressed("quit"):
			if OS.has_feature("pc"):
				_replay_system._save_replay_and_quit()
			else:
				_pause_menu_system.pause()
		elif Input.is_action_just_pressed("ui_cancel"):
			_pause_menu_system.pause()

# Private Methods


## Called when the user selects "Start Game" from the menu. Runs the test dialogue flow.
func run_test_dialogue_flow() -> void: ## async via await visitor.visit()
	# 1. Build the sequence from disk.
	var root := _sequence_builder.build_from_file("res://dialog_system/test_json.json")

	# 2. Set the flag that the first node's condition checks.
	GlobalState.set_flag(&"is_guy_happy", true)

	# 3. Create a SequenceVisitor, add it to the tree so it can use await.
	var visitor := SequenceVisitor.new()
	add_child(visitor)

	# 4. Wire up signal handlers so we can see the flow in the output log.
	visitor.show_choices.connect(func(choices: Array) -> void:
		print("[DIALOGUE] Choices:")
		for i in choices.size():
			print("  [", i, "] ", choices[i])
		# Auto-select the first choice so the test runs without manual input.
		visitor.choose.call_deferred(0)
	)
	visitor.show_line.connect(func(line: String) -> void:
		print("[DIALOGUE] ", line)
		visitor.advance.call_deferred()
		visitor.advance.call_deferred()
	)
	visitor.dialogue_ended.connect(func() -> void:
		print("[DIALOGUE] Dialogue ended, control returned to player.")
		visitor.queue_free()
	)

	# 5. Start traversal and wait for it to fully complete.
	await visitor.visit(root, player_input)

	# Verify the before_dialogue callback set is_guy_happy to false.
	assert(GlobalState.get_flag(&"is_guy_happy") == false)
