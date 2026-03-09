extends Node

## Simple map of callback identifier (StringName) -> Callable.
## Uses static state so no autoload or instance is needed.
## Access via CallbackRegistry.register() / CallbackRegistry.get_callback() anywhere.

static var _callbacks: Dictionary = {}

# equivalent of "ready" function but for static variables,
# and is called on the first time the clas is first used.
static func _static_init() -> void:
	_callbacks[&"set_happy_acknowledged"] = _set_happy_acknowledged
	_callbacks[&"clear_text_buffer"] = _clear_text_buffer


static func register(identifier: StringName, callable: Callable) -> void:
	_callbacks[identifier] = callable


static func get_callback(identifier: StringName) -> Variant:
	return _callbacks.get(identifier, null)


static func has_callback(identifier: StringName) -> bool:
	return _callbacks.has(identifier)


# The conditions

static func _set_happy_acknowledged(value: bool):
	print("setting happy acknowledged to: ", value)
	GlobalState.set_flag(&"is_guy_happy", value)


static func _clear_text_buffer():
	pass
