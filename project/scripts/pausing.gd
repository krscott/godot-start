class_name Pausing
extends Node

signal pre_pause


var paused := false


func pause() -> void:
	paused = true


func unpause() -> void:
	paused = false


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS


func _physics_process(_delta: float) -> void:
	if paused != get_tree().paused:
		if paused:
			print("PAUSED")
			pre_pause.emit()
		else:
			print("UNPAUSED")

		get_tree().paused = paused
