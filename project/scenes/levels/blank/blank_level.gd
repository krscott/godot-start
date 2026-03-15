extends Node

func _init() -> void:
	@warning_ignore("standalone_expression")
	gdserde


func _process(_delta: float) -> void:
	get_tree().quit()
