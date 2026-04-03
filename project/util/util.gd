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


## WARNING: False negative if obj has member but set to null
static func has_member(obj: Object, name: StringName) -> bool:
	return obj.get(name) != null


## NOTE: This method is slow. Prefer `has_member` for non-nullable fields
static func has_member_nullable(obj: Object, name: StringName) -> bool:
	return name in util.get_field_names(obj)


static func get_or_default(obj: Object, name: StringName, default: Variant) -> Variant:
	var value: Variant = obj.get(name)
	if value == null:
		return default
	return value


## Fixes error "Failed to encode a path to a custom script for an array type."
static func safe_var_to_str(variant: Variant) -> String:
	match typeof(variant):
		# Add more types as necessary
		TYPE_ARRAY, TYPE_OBJECT:
			return str(variant)
		_:
			return var_to_str(variant)


static func get_field_names(obj: Object) -> Array[String]:
	var out: Array[String] = []
	for prop: Dictionary in obj.get_property_list():
		var name: String = prop.name
		match name:
			"RefCounted", "script", "Script Variables", "__meta__", "Built-in script":
				continue
		out.push_back(name)
	return out


static func a_ok(err: Error, context := "") -> void:
	if err:
		var msg := error_string(err)
		if context:
			msg = str(msg, context, " (", msg, ")")
		assert(false, msg)
		printerr(msg)


static func expect_ok(err: Error, context := "") -> void:
	a_ok(err, context)


static func a_true(x: bool, context := "") -> void:
	assert(x, context)


static func a_false(x: bool, context := "") -> void:
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


static func parse_json_file(path: String) -> Result:
	var text := FileAccess.get_file_as_string(path)
	if text == "":
		return Result.error(FileAccess.get_open_error())
	var data: Variant = JSON.parse_string(text)
	if data == null:
		return Result.error(ERR_PARSE_ERROR)
	return Result.ok(data)


## Print a stack previously captured with `get_stack()`
static func print_saved_stack(stack: Array, start: int = 0) -> void:
	for i in stack.size():
		if i < start:
			continue
		var frame: Dictionary = stack[i]
		print(
			"  %s:%d - %s()" % [
				frame.source,
				frame.line,
				frame.function,
			],
		)


static func msg_unexpected_type(expected_type: Variant.Type, actual_value: Variant) -> String:
	return str(
		"expected ",
		type_string(expected_type),
		", got ",
		type_string(typeof(actual_value)),
		": ",
		util.safe_var_to_str(actual_value),
	)


static func transform_3d(
		position: Vector3 = Vector3.ZERO,
		rotation: Vector3 = Vector3.ZERO,
		scale: Vector3 = Vector3.ONE,
) -> Transform3D:
	var base := Basis.from_euler(rotation)
	base.x *= scale.x
	base.y *= scale.y
	base.z *= scale.z
	return Transform3D(base, position)


static func rand_index(arr: Array) -> int:
	return randi_range(0, arr.size() - 1)
