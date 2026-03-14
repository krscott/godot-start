extends Node

func _init() -> void:
	@warning_ignore("standalone_expression")
	gdserde


func _ready() -> void:
	get_tree().quit()
