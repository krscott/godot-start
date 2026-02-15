## Component for serializing/deserializing all nodes of a group
## NOTE: All/only nodes that are in the group at _ready() are managed--
##       adding or removing nodes from the group may cause unexpected behavior
class_name PersistGroup
extends Node

const gdserde_class := &"PersistGroup"

@export var unique_state_key: String
@export var group_name := &"persist"

## Unique node keys (relative path)
var _keys: Array[String] = []
## References to nodes
var _nodes: Array[Node] = []
var _output := { }


func gdserde_serialize() -> Variant:
	assert(_keys.size() == _nodes.size())
	_output.clear()
	for i in range(_keys.size()):
		var key := _keys[i]
		var node := _nodes[i]
		if is_instance_valid(node):
			_output[key] = GdSerde.serialize(_nodes[i])
		else:
			assert(false, str("Attempted to serialize invalid instance: ", key))
	return _output


func gdserde_deserialize(dict: Dictionary) -> Error:
	assert(_keys.size() == _nodes.size())
	var err := OK
	for i in range(_keys.size()):
		var key := _keys[i]
		if key in dict:
			var value: Dictionary = dict[key]
			var node := _nodes[i]
			if is_instance_valid(node):
				var err2 := GdSerde.deserialize_object(node, value)
				if err2 != OK:
					printerr("Error deserializing ", key, ": ", error_string(err2))
					err = err2
			else:
				assert(false, str("Attempted to deserialize invalid instance: ", key))
				err = FAILED
	return err


func _ready() -> void:
	assert(unique_state_key, "Must specify project-unique state key string")
	assert(group_name)

	var parent := get_parent()

	await parent.ready

	_keys.clear()
	_nodes.clear()
	for node in parent.get_tree().get_nodes_in_group(group_name):
		if parent.is_ancestor_of(node):
			var key: String
			if node.unique_name_in_owner:
				key = node.name
			else:
				key = str(parent.get_path_to(node, true))
			print(key)
			_keys.push_back(key)
			_nodes.push_back(node)
			assert(_keys.size() == _nodes.size())

	gamestate.sync_object_state(unique_state_key, self)
