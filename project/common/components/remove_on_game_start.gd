class_name RemoveOnGameStart
extends Node

func _ready() -> void:
	await gamestate.game_started_pub.turned_on
	get_parent().queue_free()
