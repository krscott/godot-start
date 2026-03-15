class_name DialogueData
const gdserde_class = &"DialogueData"
static var gdserde_props := {
	&"events": _deser_events,
}

## Dictionary[String, DialogueEvent]
var events: Dictionary


static func _deser_events(original: Dictionary, value: Variant) -> Array:
	var d := util.as_dict(value)
	var err := OK

	original.clear()

	for k: String in d:
		var event := DialogueEvent.new()
		var err2 := GdSerde.deserialize_object(event, util.as_dict(d[k]))
		if err2:
			assert(false)
			err = err2
		else:
			original[k] = event

	return [original, err]
