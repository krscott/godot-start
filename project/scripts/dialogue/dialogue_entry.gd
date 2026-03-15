class_name DialogueEntry
extends Node

@export_file("*.json") var json_path: String

var _dialogue_data := DialogueData.new()


func _ready() -> void:
	match util.parse_json_file(json_path):
		[var data, OK]:
			var res := gdserde.deserialize_object(_dialogue_data, data)
			res.expect_ok()
			print(gdserde.serialize_object(_dialogue_data))
		[_, var err]:
			util.aok(util.as_err(err))


func _process(_delta: float) -> void:
	pass
