class_name util


const MAX_INT: int = 9223372036854775807
const MIN_INT: int = -9223372036854775807 - 1

static func set_mouse_captured(is_caputred: bool) -> void:
	if is_caputred:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

static func is_mouse_captured() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

static func has_member(obj: Object, name: StringName) -> bool:
	return obj.get(name) != null

static func aok(err: Error, context := "") -> void:
	if err:
		var msg := error_string(err)
		if context:
			msg = str(msg, context, " (", msg, ")")
		assert(false, msg)
		printerr(msg)

static func expect_ok(err: Error, context := "") -> void:
	aok(err, context)

static func expect_true(x: bool, context := "") -> void:
	assert(x, context)

## Tries to cast Variant to Dictionary, otherise returns empty Dictionary
static func try_as_dict(x: Variant) -> Dictionary:
	if x is Dictionary:
		var dict: Dictionary = x
		return dict
	return {}

## Tries to cast Variant to Object, otherise returns null
static func try_as_obj(x: Variant) -> Object:
	if x is Object:
		var obj: Object = x
		return obj
	return null
