class_name util


const MAX_INT: int = 9223372036854775807
const MIN_INT: int = -9223372036854775807 - 1

static func set_mouse_captured(is_caputred: bool) -> void:
	if is_caputred:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

static func has_member(obj: Object, name: StringName) -> bool:
	return obj.get(name) != null

static func aok(err: Error) -> void:
	if err:
		assert(false, error_string(err))
		printerr(error_string(err))
