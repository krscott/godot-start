extends Node

@export var menu: Menu


func _ready() -> void:
	assert(menu)
	_build_menu()

	util.a_ok(gamestate.game_paused.turned_on.connect(_show_menu))
	util.a_ok(gamestate.game_paused.turned_off.connect(_hide_menu))

	if gamestate.show_menu_on_startup:
		_show_menu()


func _quit() -> void:
	signalbus.quitting.emit()
	get_tree().call_deferred(&"quit")


func _save_game_dialog() -> void:
	var filename: String = await overlay.system_dialog.file_save_dialog("*.sav", "Save File")
	if filename:
		util.a_ok(overlay.save_state.save_to_file(filename))


func _load_game_dialog() -> void:
	var filename: String = await overlay.system_dialog.file_open_dialog("*.sav", "Save File")
	if filename:
		var err: Error = overlay.save_state.load_from_file(filename)
		assert(not err)


func _build_menu() -> void:
	menu.build(
		[
			Menu.button("Start Game", signalbus.unpause_requested.emit) #
			.visible_when(gamestate.game_started.is_on) #
			.focus(),
			Menu.button("Continue", signalbus.unpause_requested.emit) #
			.action("ui_cancel") #
			.visible_when(gamestate.game_started.is_off) #
			.focus(),
			Menu.button("Save Game", _save_game_dialog) #
			.visible_when(_menu_visible) #
			.desktop_only(),
			Menu.button("Load Game", _load_game_dialog) #
			.desktop_only(),
			#Menu.button("Load Replay", replay_system._replay_open_dialog) #
			#.desktop_only(),
			Menu.checkbox("Palette Filter", gamestate.palette_filter.set_state) #
			.toggled(gamestate.palette_filter.state),
			Menu.checkbox("Dither Filter", gamestate.dither_filter.set_state) #
			.toggled(gamestate.dither_filter.state),
			Menu.button("Quit", _quit) #
			.desktop_only(),
		],
	)


func _show_menu() -> void:
	menu.show()


func _hide_menu() -> void:
	menu.hide()


func _menu_visible() -> bool:
	return menu.visible
