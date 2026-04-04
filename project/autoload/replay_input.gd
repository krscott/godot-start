extends Node

## bit -> action mapping
var _action_bits: Array[StringName] = []

var _frame_count := 0


class ReplayFrame:
	const type_name := &"ReplayFrame"


	func type_def() -> Dictionary:
		return {
			&"just_pressed": Type.dict(TYPE_STRING_NAME, Type.native(TYPE_BOOL)),
			&"pressed": Type.dict(TYPE_STRING_NAME, Type.native(TYPE_BOOL)),
		}


	var just_pressed: Dictionary
	var pressed: Dictionary


func _physics_process(_delta: float) -> void:
	_frame_count += 1


func _set_packed_byte(dict: Dictionary, action: StringName, value: bool) -> bool:
	if not value:
		return false

	@warning_ignore("integer_division")
	var i := _frame_count / 8
	var b := posmod(_frame_count, 8)

	var buf: PackedByteArray
	if action in dict:
		buf = dict[action]
	else:
		buf = PackedByteArray()
		dict[action] = buf

	util.a_ok(buf.resize(i + 1))

	var new_byte := buf.get(i) & (1 << b)
	buf.set(i, new_byte)

	return true

	#func is_action_just_pressed(action: StringName) -> bool:
	#return _set_packed_byte(
	#_just_pressed, action, Input.is_action_just_pressed(action)
	#)
#
#func is_action_pressed(action: StringName) -> bool:\
#return _set_packed_byte(
#_pressed, action, Input.is_action_just_pressed(action)
#)
