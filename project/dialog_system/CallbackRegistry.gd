class_name CallbackRegistry
extends Object

## Simple map of callback identifier (StringName) -> Callable.
## Uses static state so no autoload or instance is needed.
## Access via CallbackRegistry.register() / CallbackRegistry.get_callback() anywhere.

static var _callbacks: Dictionary = {
	set_happy_acknowledged: callable(self , "_set_happy_acknowledged"),
	clear_text_buffer: callable(self , "_clear_text_buffer")
} # StringName -> Callable


static func register(identifier: StringName, callable: Callable) -> void:
	_callbacks[identifier] = callable


static func get_callback(identifier: StringName) -> Variant:
	return _callbacks.get(identifier, null)


static func has_callback(identifier: StringName) -> bool:
	return _callbacks.has(identifier)


# The conditions

static func _set_happy_acknowledged():
	pass


static func _clear_text_buffer():
	pass
