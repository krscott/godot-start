class_name SequenceBuilder
extends RefCounted

var root_node: CaptiveSequenceNode


func process_link_entry(data: Variant, link_to_node_map: Dictionary) -> Link:
	var new_link := Link.new()
	# Process conditions asdf
	if data.has("conds"):
		for condition in data["conds"]:
			var new_condition := DialogueCondition.new()
			# Look up conditions in a global dictionary of conditions. 
			var cond_callable = ConditionRegistry.get_condition(condition["identifier"])
			if cond_callable == null:
				push_error("Condition identifier not found in global registry: " + condition["identifier"])
			else:
				new_condition.set_eval_condition(cond_callable)
				new_condition.set_eval_args([condition["value"]])
				new_link.add_condition(new_condition) #
			
	# Process text
	if data.has("text"):
		for line in data["text"]:
			new_link.add_line(line)

	# Process callbacks
	print("debugging data: ", data)
	if data.has("callbacks"):
		var callbacks_to_add: Dictionary = {} # callback_type -> Callable
		for callback_type in data["callbacks"].keys(): # ex: "before_dialogue"
			for id_valuepair in data["callbacks"][callback_type]:
				var cb_callable = CallbackRegistry.get_callback(id_valuepair["identifier"])
				if cb_callable == null:
					push_error("Callback identifier not found in global registry: " + id_valuepair["identifier"])
				else:
					var callback_args = id_valuepair["values"]
					callbacks_to_add[callback_type] = cb_callable.bindv(callback_args)
		new_link.set_callbacks(callbacks_to_add)
	
	# Add the ID of the next node to the mapping 
	# It's a mapping of this LINK to NEXT NODE.
	if data.has("next"):
		link_to_node_map[new_link] = data["next"]

	return new_link


## Build one CaptiveSequenceNode from a top-level value.
## node_id: the key (e.g. "talk_some_guy_01"). data: either an Array of link dicts or a single link dict.
func process_node_entry(node_id: String, data: Variant, link_to_node_map: Dictionary) -> CaptiveSequenceNode:
	var new_node := CaptiveSequenceNode.new()
	new_node.set_id(node_id)

	if data is Array:
		for link_data in data:
			var new_link := process_link_entry(link_data, link_to_node_map)
			new_node.add_link(new_link)
	elif data is Dictionary:
		var new_link := process_link_entry(data, link_to_node_map)
		new_node.add_link(new_link)
	else:
		push_error("process_node_entry: expected Array or Dictionary, got %s" % type_string(typeof(data)))

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
	root_node.set_id("root")

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
			var new_node := process_node_entry(node_id, data_received[node_id], link_to_node_map)
			node_id_to_node_map[node_id] = new_node

		# Now connect links, which will be in the construction map.
		for link in link_to_node_map.keys():
			var next_link_node_id = link_to_node_map[link]
			if next_link_node_id != null:
				var next_node = node_id_to_node_map[next_link_node_id]
				link.set_next_node(next_node)
			

	return root_node
