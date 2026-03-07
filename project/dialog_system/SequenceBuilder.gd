class_name SequenceBuilder
extends RefCounted

var root_node: CaptiveSequenceNode
var conditions_global_registry: %ConditionRegistry
var callbacks_global_registry: %CallbackRegistry


func process_link_entry(data: Variant, link_to_node_map: Dictionary) -> Link:
	var new_link := Link.new()
	# Process conditions
	if data["conds"] != null:
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
	if data["text"] != null:
		for line in data["text"]:
			new_link.add_line(line)

	# Process callbacks
	if data["callbacks"] != null:
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
		link_to_node_map[new_link] = data["next"]

	return new_link


func process_node_entry(data: Variant, construction_map: Dictionary) -> void:
	var new_node := CaptiveSequenceNode.new()
	new_node.name = data["id"]
	new_node.set_id(data["id"])
	for link_id in data["links"]:
		var new_link := process_link_entry(data["links"][link_id], construction_map)
		new_node.add_link(new_link)

	return new_node
	

# ASSUMPTION: All nodes that can reach each other are in the same file.

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

	var node_id_to_node_map := {}
	var link_to_node_map := {} # Maps which links will connect to which following nodes.

	# Now, recursively build the tree based on the JSON.
	# It will be a "Variant"
	var json = JSON.new()
	var error := json.parse(file_text)


	if error == OK:
		var data_received = json.data
		# Now, recursively process the entries.

		# For each key in the top-level JSON, create the node and add it to the map
		for node_id in data_received.keys():
			var new_node := process_node_entry(data_received[node_id], link_to_node_map)
			node_id_to_node_map[node_id] = new_node
			for json_object in data_received[node_id]:
				var new_link := process_link_entry(json_object, link_to_node_map)
				new_node.add_link(new_link)

		# Now connect links, which will be in the construction map.
		for link in link_to_node_map.keys():
			var next_link_node_id = link_to_node_map[link]
			if next_link_node_id != null:
				var next_node = node_id_to_node_map[next_link_node_id]
				link.set_next_node(next_node)
			

	return root_node
