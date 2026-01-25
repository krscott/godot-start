class_name util

const MAX_INT: int = 9223372036854775807
const MIN_INT: int = -9223372036854775807 - 1

static func mouse_capture() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

static func mouse_show() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
