class_name Pausing
extends Node


var paused := false


func pause() -> void:
	paused = true


func unpause() -> void:
	paused = false


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS


func _physics_process(_delta: float) -> void:
	if paused != get_tree().paused:
		get_tree().paused = paused
