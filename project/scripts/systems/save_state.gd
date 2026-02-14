class_name SaveState
extends Node


signal savedata_saving
signal savedata_loaded


## Dictionary[StringName, Dictionary]
var _savedata_state := {}
## Dictionary[StringName, Object]
var _savedata_refs := {}

## Player quick save
var _quick_save: PackedByteArray
## Save of initial game state
var _quick_save_zero: PackedByteArray


# Public Methods

func update_state(key: StringName, obj: Object) -> void:
	_savedata_state[key] = GdSerde.serialize_object(obj)


func load_state(key: StringName, obj: Object) -> void:
	if _savedata_state.has(key):
		var dict: Dictionary = _savedata_state[key]
		util.aok(GdSerde.deserialize_object(obj, dict))


func sync_state(key: StringName, obj: Object) -> void:
	util.printdbg("Sync state: ", key)

	load_state(key, obj)
	if OS.is_debug_build():
		# Debug-only check for serde errors
		var dict := GdSerde.serialize_object(obj)
		util.aok(GdSerde.deserialize_object(obj, dict))

	_savedata_refs[key] = obj


func quicksave() -> void:
	_quick_save = _serialize_savedata()


func quickload() -> void:
	_deserialize_savedata(_quick_save)


func reset() -> void:
	_deserialize_savedata(_quick_save_zero)


# Interface Methods

func _ready() -> void:
	call_deferred(&"_root_ready")


# Private Methods

func _root_ready() -> void:
	_quick_save_zero = _serialize_savedata()
	_quick_save = _quick_save_zero


func _deserialize_savedata(packed_data: PackedByteArray) -> void:
	var unpacked_state: Variant = bytes_to_var(packed_data)
	if unpacked_state is not Dictionary:
		printerr("Save data is not a Dictionary")
		return
		
	_savedata_state = unpacked_state
	
	for k: StringName in _savedata_refs:
		if is_instance_valid(_savedata_refs[k]):
			var obj: Object = _savedata_refs[k]
			load_state(k, obj)
		else:
			util.expect_true(_savedata_refs.erase(k))

	if OS.is_debug_build():
		util.printdbg("Loaded savedata: ", JSON.stringify(_savedata_state))
	savedata_loaded.emit()


func _serialize_savedata() -> PackedByteArray:
	savedata_saving.emit()

	for k: StringName in _savedata_refs:
		if is_instance_valid(_savedata_refs[k]):
			var obj: Object = _savedata_refs[k]
			update_state(k, obj)
		else:
			util.expect_true(_savedata_refs.erase(k))
	
	if OS.is_debug_build():
		util.printdbg("Saved savedata: ", JSON.stringify(_savedata_state))
	return var_to_bytes(_savedata_state)
