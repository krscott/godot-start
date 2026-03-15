class_name DialogueEvent
const gdserde_class = &"DialogueEvent"


static func gdserde_fields() -> Array[gdserde.Field]:
	return [
		gdserde.Field.native(&"conds", TYPE_PACKED_STRING_ARRAY).optional(),
		gdserde.Field.native(&"speaker", TYPE_STRING).optional(),
		gdserde.Field.native(&"text", TYPE_PACKED_STRING_ARRAY).optional(),
		gdserde.Field.native(&"next", TYPE_PACKED_STRING_ARRAY).optional(),
		gdserde.Field.new(&"choices", gdserde.Spec.array(gdserde.Spec.object(DialogueChoice.new))).optional(),
	]


class DialogueChoice:
	const gdserde_class = &"DialogueChoice"
	var text: String
	var next: String


var conds: PackedStringArray
var speaker: String
var text: PackedStringArray
var next: PackedStringArray
var choices: Array[DialogueChoice]
