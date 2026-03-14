class_name util

const MAX_INT: int = 9223372036854775807
const MIN_INT: int = -9223372036854775807 - 1


static func printdbg(...args: Array) -> void:
	if OS.is_debug_build():
		print.callv(args)


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


static func expect_false(x: bool, context := "") -> void:
	assert(not x, context)


## Casts Variant to String, otherise asserts and returns empty String
static func as_str(x: Variant) -> String:
	if x is String:
		var s: String = x
		return s
	return ""


## Tries to cast Variant to Dictionary, otherise returns empty Dictionary
static func try_as_dict(x: Variant) -> Dictionary:
	if x is Dictionary:
		var dict: Dictionary = x
		return dict
	return { }


## Casts Variant to Dictionary, otherise asserts and returns empty Dictionary
static func as_dict(x: Variant) -> Dictionary:
	if x is Dictionary:
		var dict: Dictionary = x
		return dict
	assert(false)
	return { }


## Tries to cast Variant to Object, otherise returns null
static func try_as_obj(x: Variant) -> Object:
	if x is Object:
		var obj: Object = x
		return obj
	return null


## Casts Variant to Error type, otherwise returns ERR_BUG
static func as_err(x: Variant) -> Error:
	if x is Error or x is int:
		return x
	assert(false)
	return ERR_BUG


## returns [Variant, Error]
static func parse_json_file(path: String) -> Array:
	var text := FileAccess.get_file_as_string(path)
	if text == "":
		return [null, FileAccess.get_open_error()]
	var data: Variant = JSON.parse_string(text)
	if data == null:
		return [null, ERR_PARSE_ERROR]
	return [data, OK]
