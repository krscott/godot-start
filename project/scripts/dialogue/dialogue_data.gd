class_name DialogueData
const gdserde_class = &"DialogueData"
static func gdserde_fields() -> Array[gdserde.Field]:
	return [
		gdserde.Field.new(&"events", gdserde.Spec.dict(TYPE_STRING, gdserde.Spec.object(DialogueEvent.new)))
	]

## Dictionary[String, DialogueEvent]
var events: Dictionary
