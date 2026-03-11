extends Area3D

var _triggered := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if _triggered:
		return
	if body is CharacterBody3D:
		_triggered = true
		body.set_physics_process(false)
		await gamestate.run_test_dialogue_flow()
		body.set_physics_process(true)
		_triggered = false
