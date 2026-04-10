class_name FocusOnReady
extends Node

func _ready() -> void:
	var parent: Control = get_parent()
	assert(parent)
	parent.grab_focus()
	queue_free()
