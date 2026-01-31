class_name Popupper
extends Node

signal completed(string: String)

func _on_completed(filename: String = "") -> void:
	completed.emit(filename)

static func file_dialog(
	parent: Node, 
	file_mode: FileDialog.FileMode, 
	filter: String = "", 
	description: String = ""
) -> String:
	var pop := Popupper.new()
	parent.add_child(pop)
	
	var fd := FileDialog.new()
	pop.add_child(fd)
	
	fd.file_mode = file_mode
	fd.use_native_dialog = true
	if filter:
		fd.add_filter(filter, description)
	fd.popup_centered()
	
	util.expect_ok(fd.file_selected.connect(pop._on_completed))
	util.expect_ok(fd.canceled.connect(pop._on_completed))
	
	var filename: String = await pop.completed
	
	if filename:
		print("filename: ", filename)
	else:
		print("canceled")
	
	fd.queue_free()
	pop.queue_free()
	return filename

static func file_open_dialog(
	parent: Node,
	filter: String = "",
	description: String = ""
) -> String:
	return await file_dialog(parent, FileDialog.FileMode.FILE_MODE_OPEN_FILE, filter, description)
