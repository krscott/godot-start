class_name util


const MAX_INT: int = 9223372036854775807
const MIN_INT: int = -9223372036854775807 - 1

static func is_mouse_captured() -> bool:
	return Input.get_mouse_mode()

static func mouse_capture() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

static func mouse_show() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

static func has_member(obj: Object, name: StringName) -> bool:
	return obj.get(name) != null

static func expect_ok(err: Error) -> void:
	if err:
		assert(false, error_string(err))
		printerr(error_string(err))
