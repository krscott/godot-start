class_name DialogueEntry
extends Node

@export_file("*.json") var json_path: String

var _dialogue_data := DialogueData.new()


func _ready() -> void:
	match util.parse_json_file(json_path):
		[var data, OK]:
			assert(data is Dictionary)
			util.aok(
				GdSerde.deserialize_object(
					_dialogue_data,
					util.try_as_dict(data),
				),
			)
			print(GdSerde.serialize_object(_dialogue_data))
		[_, var err]:
			util.aok(util.as_err(err))


func _process(_delta: float) -> void:
	pass
