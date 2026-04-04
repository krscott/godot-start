extends Node

var _replay_tape := DataTape.new()
var _current_frame := { }
var _is_replaying := false


func is_replaying() -> bool:
	return _is_replaying


func start() -> void:
	_replay_tape.rewind()
	_is_replaying = true


func stop() -> void:
	_is_replaying = false


func size() -> int:
	return _replay_tape.size()


func _physics_process(_delta: float) -> void:
	if _is_replaying and _replay_tape.done():
		stop()

	# TODO: Better compress empty frames?
	if _is_replaying:
		match _replay_tape.take():
			null:
				_current_frame.clear()
			var d:
				_current_frame = d
	else:
		if _current_frame.is_empty():
			print(null)
			_replay_tape.append(null)
		else:
			print(_current_frame)
			_replay_tape.append(_current_frame)
		_current_frame.clear()


## (kind: StringName, action: StringName, value: T, zero: T) -> T
func _poll(kind: StringName, action: StringName, value: Variant, zero: Variant) -> Variant:
	assert(typeof(value) == typeof(zero))
	if _is_replaying:
		value = util.dict_get_or_add_dict(_current_frame, kind).get(action, zero)
	elif value:
		util.a_true(util.dict_get_or_add_dict(_current_frame, kind).set(action, value))
	return value


func is_action_just_pressed(action: StringName) -> bool:
	return _poll(&"just_pressed", action, Input.is_action_just_pressed(action), false)


func is_action_pressed(action: StringName) -> bool:
	return _poll(&"pressed", action, Input.is_action_pressed(action), false)


func get_axis(negative_action: StringName, positive_action: StringName) -> float:
	# TODO: more efficient way to find action key
	var action := str(negative_action, ",", positive_action)

	return _poll(&"axis", action, Input.get_axis(negative_action, positive_action), 0.0)


func get_vector(
		negative_x: StringName,
		positive_x: StringName,
		negative_y: StringName,
		positive_y: StringName,
		deadzone: float = -1.0,
) -> Vector2:
	# TODO: more efficient way to find action key
	var action := str(negative_x, ",", positive_x, ",", negative_y, ",", positive_y)

	return _poll(
		&"vector",
		action,
		Input.get_vector(negative_x, positive_x, negative_y, positive_y, deadzone),
		Vector2.ZERO,
	)
