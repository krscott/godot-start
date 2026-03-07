class_name Link
extends RefCounted

var id: String
var sequence_script: CaptiveSequenceScript
var lines: Array[String] = []
var conditions: Array[DialogueCondition] = []
var next_node: CaptiveSequenceNode
var callbacks: Dictionary = {}


func get_id() -> String:
	return id

func set_id(id: String) -> void:
	id = id

func get_lines() -> Array[String]:
	return lines

func set_lines(lines: Array[String]) -> void:
	lines = lines

func add_line(line: String) -> void:
	lines.append(line)

func remove_line(line: String) -> void:
	lines.erase(line)

func remove_all_lines() -> void:
	lines.clear()

func get_sequence_script() -> CaptiveSequenceScript:
	return sequence_script

func set_sequence_script(new_script: CaptiveSequenceScript) -> void:
	sequence_script = new_script

func get_conditions() -> Array[DialogueCondition]:
	return conditions

func set_conditions(conditions: Array[DialogueCondition]) -> void:
	conditions = conditions

func add_condition(condition: DialogueCondition) -> void:
	conditions.append(condition)

func remove_condition(condition: DialogueCondition) -> void:
	conditions.erase(condition)

func remove_all_conditions() -> void:
	conditions.clear()

func get_next_node() -> CaptiveSequenceNode:
	return next_node

func set_next_node(node: CaptiveSequenceNode) -> void:
	next_node = node

func is_available() -> bool:
	for condition in conditions:
		if not condition.evaluate():
			return false
	return true

func get_callbacks() -> Dictionary:
	return callbacks

func set_callbacks(callbacks: Dictionary) -> void:
	callbacks = callbacks

func add_callback(callback: String, args: Array[Variant]) -> void:
	callbacks[callback] = args

func get_choice_line() -> String:
	return lines[0]