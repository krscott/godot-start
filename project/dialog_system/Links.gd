var script: Script
var lines: Array[String] = []
var conditions: Array[DialogCondition] = []
var next_node: CaptiveSequenceNode

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


func get_script() -> Script:
	return script

func set_script(script: Script) -> void:
	script = script

func get_conditions() -> Array[DialogCondition]:
	return conditions

func set_conditions(conditions: Array[DialogCondition]) -> void:
	conditions = conditions

func add_condition(condition: DialogCondition) -> void:
	conditions.append(condition)

func remove_condition(condition: DialogCondition) -> void:
	conditions.erase(condition)

func remove_all_conditions() -> void:
	conditions.clear()

func get_next_node() -> CaptiveSequenceNode:
    pass

func set_next_node(node: CaptiveSequenceNode) -> void:
	next_node = node

func is_available() -> bool:
	print("debugging conditions: ", conditions)
    for condition in conditions:
        print("debugging condition: ", condition)
        if not condition.evaluate():
            print("condition not met")
            return false
    print("condition met")
    return true