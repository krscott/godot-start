class_name SequenceBuilder
extends Node

func build_from_file(filepath: String) -> Sequence:
    # read the file
    # parse yaml -> JSON
    # Walk JSON depth-first, building nodes and links
    # Return the root node
    var file := FileAccess.open(filepath, FileAccess.READ)
    var yaml := YAML.parse(file.get_as_text())
    var json := JSON.print(yaml, "\t")
    var root_node := Node.new()
    root_node.name = "root"
    root_node.add_child(Node.new())
    return root_node

func debug_build_from_file(filepath: String) -> void:
    var sequence := build_from_file(filepath)
    print(sequence)