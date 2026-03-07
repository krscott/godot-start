class_name SequenceBuilder
extends RefCounted

var root_node: CaptiveSequenceNode
var conditions_global_registry: %ConditionRegistry
var callbacks_global_registry: %CallbackRegistry


func process_link_entry(data: Variant, construction_map: Dictionary) -> Link:
	var new_link := Link.new()
	# Process conditions
	if data["conds"]
		for condition in data["conds"]:
			var new_condition := DialogueCondition.new()
			# Look up conditions in a global dictionary of conditions.
			if not conditions_global_registry[condition["identifier"]] == null:
				throwError("Condition identifier not found in global registry: " + condition["identifier"])
			else:
				new_condition.set_eval_condition(conditions_global_registry[condition["identifier"]])
				new_condition.set_eval_args([condition["value"]])
				new_link.add_condition(new_condition)
			

	# Process text
	if data["text"]
		for line in data["text"]:
			new_link.add_line(line)

	# Process callbacks
	if data["callbacks"]:
		var callbacks_to_add: Array[Callable] = {}
		for callback_type in data["callbacks"].keys(): # ex: "before_dialogue"
			for id_valuepair in data["callbacks"][callback_type]:
				# Look up callbacks in a global dictionary of callbacks.
				if not callbacks_global_registry[id_valuepair["identifier"]] == null:
					throwError("Callback identifier not found in global registry: " + id_valuepair["identifier"])
				else:
					callbacks_to_add[callback_type] = callbacks_global_registry[id_valuepair["identifier"]]
					var callback_args = id_valuepair["values"]
					callbacks_to_add[callback_type] = callbacks_to_add[callback_type].bind(callback_args)
		new_link.set_callbacks(callbacks_to_add)
	
	# Add the ID of the next node to the mapping 
	# It's a mapping of this LINK to NEXT NODE.
	if data["next"] != null:
		construction_map[new_link.get_id()] = data["next"]

	return new_link


func process_nodes_entry(data: Variant, construction_map: Dictionary) -> void:
	for key in data.keys():
		var new_node := CaptiveSequenceNode.new()
		new_node.name = key
		new_node.set_id(key)
		process_nodes_entry(data[key], construction_map)


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

	var construction_map := {}

	# Now, recursively build the tree based on the JSON.
	# It will be a "Variant"
	var json = JSON.new()
	var error := json.parse(file_text)


	if error == OK:
		var data_received = json.data
		# Now, recursively process the entries.
		process_json_entry(data_received, root_node, construction_map)


	return root_node

func debug_build_from_file(filepath: String) -> void:
	var sequence := build_from_file(filepath)
	print(sequence)
