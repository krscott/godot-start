extends Node

## Holds a RefCounted SequenceBuilder so it can be referenced from the scene (%SequenceBuilder)
## while the builder itself stays RefCounted and is cleaned up when this node is freed.

var sequence_builder: SequenceBuilder


func _ready() -> void:
	sequence_builder = SequenceBuilder.new()
