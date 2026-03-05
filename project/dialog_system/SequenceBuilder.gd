class_name SequenceBuilder
extends Node

var root_node: CaptiveSequenceNode

func process_json_entry(data: Variant, parent: CaptiveSequenceNode) -> void:
	# For each key, create CaptiveSequenceNode with the key name as the node's ID
	# Handle possible data types here.
	if typeof(data) == TYPE_DICTIONARY:
		for key in data.keys():
			var new_node := CaptiveSequenceNode.new()
			new_node.name = key
			new_node.set_id(key)
			parent.add_child(new_node)
			process_json_entry(data[key], new_node)
	if typeof(data) == TYPE_ARRAY:
		for entry in data:
			process_json_entry(entry, parent)
	if typeof(data) == TYPE_INT:
		parent.set_value(data)
	if typeof(data) == TYPE_STRING:
		parent.set_value(data)
	if typeof(data) == TYPE_BOOL:
		parent.set_value(data)
	if typeof(data) == TYPE_NIL:
		parent.set_value(null)

func build_from_file(filepath: String) -> CaptiveSequenceNode:
	# read the file
	# TODO LATER, let's assume JSON for now and parse yaml -> JSON
	# Walk JSON depth-first, building nodes and links
	# Return the root node
	var file := FileAccess.open(filepath, FileAccess.READ)
	var file_text := file.get_as_text()
	var root_node := CaptiveSequenceNode.new()
	root_node.name = "root"
	root_node.add_child(CaptiveSequenceNode.new())

	# Now, recursively build the tree based on the JSON.
	# It will be a "Variant"
	var json = JSON.new()
	var error := json.parse(file_text)


	if error == OK:
		var data_received = json.data
		# Now, recursively process the entries.
		process_json_entry(data_received, root_node)


	return root_node

func debug_build_from_file(filepath: String) -> void:
	var sequence := build_from_file(filepath)
	print(sequence)
