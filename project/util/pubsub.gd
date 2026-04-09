class_name pubsub

class Bool:
	signal changed(value: bool)
	signal turned_on
	signal turned_off

	var state: bool:
		set = set_state


	func set_state(value: bool) -> void:
		if state != value:
			state = value
			changed.emit(value)
			if value:
				turned_on.emit()
			else:
				turned_off.emit()


	func turn_on() -> void:
		set_state(true)


	func turn_off() -> void:
		set_state(false)


	func get_state() -> bool:
		return state


	func is_on() -> bool:
		return state


	func is_off() -> bool:
		return not state


	func _init(value: bool = false) -> void:
		state = value
