class_name DialogueEvent
const type_name = &"DialogueEvent"


static func type_def() -> Dictionary:
	return {
		&"conds": Type.optional(),
		&"speaker": Type.optional(),
		&"text": Type.optional(),
		&"next": Type.optional(),
		&"choices": Type.optional(Type.array(Type.object(DialogueChoice))),
		# "callback" is an alias for "before" kept for backwards compatibility
		&"callback": Type.optional(Type.object(DialogueCallback)),
		&"before": Type.optional(Type.object(DialogueCallback)),
		&"after": Type.optional(Type.object(DialogueCallback)),
		&"sequence": Type.optional(Type.array(Type.object(DialogueSequenceEntry))),
	}


var conds: PackedStringArray
var speaker: String
var text: PackedStringArray
var next: PackedStringArray
var choices: Array[DialogueChoice]
var callback := DialogueCallback.new()
var before := DialogueCallback.new()
var after := DialogueCallback.new()
var sequence: Array[DialogueSequenceEntry]


class DialogueCallback:
	const type_name = &"DialogueCallback"


	static func type_def() -> Dictionary:
		return {
			&"name": null,
			&"args": Type.optional(),
		}


	var name: String
	var args: PackedStringArray


class DialogueChoice:
	const type_name = &"DialogueChoice"


	static func type_def() -> Dictionary:
		return {
			&"text": null,
			&"next": null,
			&"callback": Type.optional(Type.object(DialogueCallback)),
		}


	var text: String
	var next: String
	var callback := DialogueCallback.new()


class DialogueSequenceEntry:
	const type_name = &"DialogueSequenceEntry"


	static func type_def() -> Dictionary:
		return {
			&"speaker": Type.optional(),
			&"text": null,
		}


	var speaker: String
	var text: PackedStringArray
