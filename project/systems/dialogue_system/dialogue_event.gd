class_name DialogueEvent
const gdserde_class = &"DialogueEvent"


static func type_def() -> Dictionary:
	return {
		&"conds": Type.implicit().optional(),
		&"speaker": Type.implicit().optional(),
		&"text": Type.implicit().optional(),
		&"next": Type.implicit().optional(),
		&"choices": Type.array(Type.object(DialogueChoice)).optional(),
	}


var conds: PackedStringArray
var speaker: String
var text: PackedStringArray
var next: PackedStringArray
var choices: Array[DialogueChoice]


class DialogueCallback:
	const gdserde_class = &"DialogueCallback"


	static func type_def() -> Dictionary:
		return {
			&"name": Type.implicit(),
			&"args": Type.implicit().optional(),
		}


	var name: String
	var args: PackedStringArray


class DialogueChoice:
	const gdserde_class = &"DialogueChoice"


	static func type_def() -> Dictionary:
		return {
			&"text": Type.implicit(),
			&"next": Type.implicit(),
			&"callback": Type.object(DialogueCallback).optional(),
		}


	var text: String
	var next: String
	var callback := DialogueCallback.new()
