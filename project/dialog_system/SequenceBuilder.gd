class_name SequenceBuilder
extends Node

func build_node(node: Variant, parent: Node) -> void:
    pass

func build_from_file(filepath: String) -> Node:
    # read the file
    # TODO LATER, let's assume JSON for now and parse yaml -> JSON
    # Walk JSON depth-first, building nodes and links
    # Return the root node
    var file := FileAccess.open(filepath, FileAccess.READ)
    var file_text := file.get_as_text()
    var root_node := Node.new()
    root_node.name = "root"
    root_node.add_child(Node.new())

    # Now, recursively build the tree based on the JSON.
    # It will be a "Variant"
    var json = JSON.new()
    var error := json.parse(file_text)
    
    if error == OK:
        var data_received = json.data
        if typeof(data_received) == TYPE_DICTIONARY:
            #build_node(data_received, parent)
            print("Dictionary: ", data_received)
        elif typeof(data_received) == TYPE_ARRAY:
            for item in data_received:
                #build_node(item, parent)
                print("Array: ", item)
        else:
            printerr("Invalid JSON data: ", data_received)

    return root_node

func debug_build_from_file(filepath: String) -> void:
    var sequence := build_from_file(filepath)
    print(sequence)