extends Node

## Pan-scene key-value state (e.g. dialogue flags, story progress).
## Persists via the same save/load system as PersistGroup (GdSerde + gamestate.sync_object_state).
## Use from any scene: EventState.set_flag("talked_to_guy"), EventState.get_state("chapter") etc.

const gdserde_class := &"EventState"

## Key -> value; only Variant-friendly types (primitives, Dictionary, Array) survive serialize.
var _state: Dictionary = {}


func get_state(key: StringName) -> Variant:
	return _state.get(key, null)


func set_state(key: StringName, value: Variant) -> void:
	_state[key] = value


func has_state(key: StringName) -> bool:
	return _state.has(key)


func erase_state(key: StringName) -> bool:
	return _state.erase(key)


## Convenience for boolean flags (e.g. dialogue).
func get_flag(key: StringName) -> bool:
	return bool(_state.get(key, false))


func set_flag(key: StringName, value: bool) -> void:
	_state[key] = value


func gdserde_serialize() -> Variant:
	return _state.duplicate()


func gdserde_deserialize(dict: Dictionary) -> Error:
	_state.clear()
	for k in dict:
		_state[k] = dict[k]
	return OK


func _ready() -> void:
	gamestate.sync_object_state(&"event_state", self)
