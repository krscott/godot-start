extends Node

@export var menu: Menu


func _ready() -> void:
	assert(menu)
	_build_menu()

	util.a_ok(overlay.menu_open_pub.turned_on.connect(_open))
	util.a_ok(overlay.menu_open_pub.turned_off.connect(_close))


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
			Menu.button("Start Game", _close) #
			.visible_when(gamestate.game_started.is_on) #
			.focus(),
			Menu.button("Continue", _close) #
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
			Menu.checkbox("Palette Filter", overlay.palette_filter_pub.set_state) #
			.toggled(overlay.palette_filter_pub.state),
			Menu.checkbox("Dither Filter", overlay.dither_filter_pub.set_state) #
			.toggled(overlay.dither_filter_pub.state),
			Menu.button("Quit", _quit) #
			.desktop_only(),
		],
	)


func _open() -> void:
	menu.show()
	overlay.menu_open_pub.state = true


func _close() -> void:
	menu.hide()
	overlay.menu_open_pub.state = false


func _menu_visible() -> bool:
	return menu.visible
