extends Node

# Arbitrary value
var _rng_seed := hash("replay input")

var _replay_tape := DataTape.new()
var _current_frame := { }
var _seen_event_ids: Array[int] = []
var _rng := RandomNumberGenerator.new()
var _used_rng_this_frame := false
var _registered_signal_nodes := { }
var _replayed_signal_id := -1
var _is_replaying := false


func _clear_frame() -> void:
	_current_frame.clear()
	_seen_event_ids.clear()
	_used_rng_this_frame = false


func is_replaying() -> bool:
	return _is_replaying


func start() -> void:
	_replay_tape.rewind()
	_is_replaying = true
	get_tree().root.set_process_input(false)


func stop() -> void:
	_is_replaying = false
	get_tree().root.set_process_input(true)


func size() -> int:
	return _replay_tape.size()


func _ready() -> void:
	_rng.seed = _rng_seed


func _physics_process(_delta: float) -> void:
	if _is_replaying and _replay_tape.done():
		stop()

	# TODO: Better compress empty frames?
	if _is_replaying:
		match _replay_tape.take():
			null:
				_clear_frame()
			var d:
				_current_frame = d

		if _current_frame.has(&"events"):
			for ev_data: Dictionary in _current_frame[&"events"]:
				_fire_event(ev_data)
		if _current_frame.has(&"signals"):
			for sig_args: Array in _current_frame[&"signals"]:
				_emit_signal.callv(sig_args)
	else:
		if _current_frame.is_empty():
			#print(null)
			_replay_tape.append(null)
		else:
			#print(_current_frame)
			_replay_tape.append(_current_frame)
		_clear_frame()


# TODO: Use an enum for kind
## (kind: StringName, action: StringName, value: T, zero: T) -> T
func _poll(kind: StringName, action: StringName, value: Variant, zero: Variant) -> Variant:
	assert(typeof(value) == typeof(zero))
	if _is_replaying:
		value = util.dict_get_or_add_dict(_current_frame, kind).get(action, zero)
	elif value:
		util.a_true(util.dict_get_or_add_dict(_current_frame, kind).set(action, value))
	return value


func is_action_just_released(action: StringName) -> bool:
	return _poll(&"just_released", action, Input.is_action_just_released(action), false)


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


func get_custom(action: StringName, value: Variant, zero: Variant) -> Variant:
	return _poll(&"custom", action, value, zero)


func _fire_event(ev_data: Dictionary) -> void:
	var class_name_: StringName = ev_data[&".class"]
	var ev: InputEvent = ClassDB.instantiate(class_name_)
	for k: StringName in ev_data:
		if not k.begins_with("."):
			ev.set(k, ev_data[k])

	# IDs aren't preserved through Input.parse_input_event(), using hash instead
	_seen_event_ids.push_back(hash(str(ev)))
	print(hash(str(ev)), " ", ev)
	Input.parse_input_event(ev)


func event(ev: InputEvent, props: Array[StringName]) -> bool:
	var allow_event := true

	if _is_replaying:
		allow_event = _seen_event_ids.has(hash(str(ev)))
		print(hash(str(ev)), " ", ev, " ", allow_event)

	else:
		var id := ev.get_instance_id()
		if not _seen_event_ids.has(id):
			_seen_event_ids.push_back(id)

			var ev_data := {
				&".class": ev.get_class(),
			}
			for prop in props:
				ev_data[prop] = ev.get(prop)
			util.dict_get_or_add_array(_current_frame, &"events").push_back(ev_data)

	return allow_event


func rng() -> RandomNumberGenerator:
	assert(_rng.seed == _rng_seed, "Client code is not allowed to change RNG seed")

	if _is_replaying:
		if _current_frame.has(&"rng_state"):
			_rng.state = _current_frame[&"rng_state"]
		else:
			push_warning("Unexpected RNG call in replay")
	else:
		if not _used_rng_this_frame:
			_used_rng_this_frame = true
			_current_frame[&"rng_state"] = _rng.state

	return _rng


func _emit_signal(node_name: StringName, ...signalname_args: Array) -> void:
	var node: Node = _registered_signal_nodes[node_name]

	# TODO: Is there a cleaner way to block other signals?
	_replayed_signal_id = node.get_instance_id()
	var err: Error = node.emit_signal.callv(signalname_args)
	_replayed_signal_id = -1
	util.a_ok(err)


func _on_signal(callback: Callable, id: int, ...nodename_signalname_args: Array) -> void:
	print("============== ", nodename_signalname_args)
	var allow_callback := true

	if _is_replaying:
		allow_callback = _replayed_signal_id == id
	else:
		util.dict_get_or_add_array(_current_frame, &"signals").push_back(nodename_signalname_args)

	if allow_callback:
		# Remove signal_name from args list and call callback function
		callback.callv(nodename_signalname_args.slice(2))


func connect_signal(node: Node, signal_name: StringName, callback: Callable) -> void:
	if _registered_signal_nodes.has(node.name):
		push_warning("Re-registering node: ", node)
	_registered_signal_nodes[node.name] = node

	util.a_ok(
		node.connect(
			signal_name,
			_on_signal.bind(callback, node.get_instance_id(), node.name, signal_name),
		),
	)
