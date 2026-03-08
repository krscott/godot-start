class_name ConditionRegistry
extends Object

## Simple map of condition identifier (StringName) -> Callable.
## Uses static state so no autoload or instance is needed.
## Access via ConditionRegistry.register() / ConditionRegistry.get_condition() anywhere.

static var _conditions: Dictionary = {}  # StringName -> Callable


static func register(identifier: StringName, callable: Callable) -> void:
	_conditions[identifier] = callable


static func get_condition(identifier: StringName) -> Variant:
	return _conditions.get(identifier, null)


static func has_condition(identifier: StringName) -> bool:
	return _conditions.has(identifier)
