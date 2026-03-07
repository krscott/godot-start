class_name DialogueCondition
extends Node

var eval_condition: Callable
var eval_args: Array[Variant] = []

# Must be implemented in subclass
func evaluate() -> bool:
	return eval_condition.callv(eval_args)


func set_eval_condition(eval_condition: Callable) -> void:
	self.eval_condition = eval_condition

func set_eval_args(eval_args: Array[Variant]) -> void:
	self.eval_args = eval_args