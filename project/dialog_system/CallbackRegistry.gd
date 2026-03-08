class_name CallbackRegistry
extends Object

## Simple map of callback identifier (StringName) -> Callable.
## Uses static state so no autoload or instance is needed.
## Access via CallbackRegistry.register() / CallbackRegistry.get_callback() anywhere.

static var _callbacks: Dictionary = {}  # StringName -> Callable


static func register(identifier: StringName, callable: Callable) -> void:
	_callbacks[identifier] = callable


static func get_callback(identifier: StringName) -> Variant:
	return _callbacks.get(identifier, null)


static func has_callback(identifier: StringName) -> bool:
	return _callbacks.has(identifier)
