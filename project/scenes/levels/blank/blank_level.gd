extends Node


func _process(_delta: float) -> void:
	print("Blank level is quitting")
	get_tree().quit()
