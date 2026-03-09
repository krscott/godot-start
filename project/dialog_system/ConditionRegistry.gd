extends Node

## Simple map of condition identifier (StringName) -> Callable.
## Uses static state so no autoload or instance is needed.
## Access via ConditionRegistry.register() / ConditionRegistry.get_condition() anywhere.

static var _conditions: Dictionary = {}

# equivalent of "ready" function but for static variables,
# and is called on the first time the clas is first used.
static func _static_init() -> void:
	_conditions[&"is_guy_happy"] = _is_guy_happy


static func register(identifier: StringName, callable: Callable) -> void:
	_conditions[identifier] = callable


static func get_condition(identifier: StringName) -> Variant:
	return _conditions.get(identifier, null)


static func has_condition(identifier: StringName) -> bool:
	return _conditions.has(identifier)


# The conditions

static func _is_guy_happy(convo_state: Variant) -> bool:
	print("debugging global state: ", GlobalState.get_flag("is_guy_happy"))
	return GlobalState.get_flag("is_guy_happy")
