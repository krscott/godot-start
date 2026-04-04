class_name DialogueData
const type_name = &"DialogueData"


static func type_def() -> Dictionary:
	return {
		&"events": Type.dict(TYPE_STRING, Type.object(DialogueEvent)),
	}

## Dictionary[String, DialogueEvent]
var events: Dictionary


func check_condition(state: Object, key: String) -> bool:
	var event: DialogueEvent = events[key]
	for cond in event.conds:
		if state.has_method(cond):
			if not state.call(cond):
				print("found: ", cond)
				return false
		assert(util.has_member(state, cond), str("State is missing condition: ", cond))
		if not state.get(cond):
			print("found: ", cond)
			return false
	return true


func get_next(state: Object, key: String) -> String:
	var event: DialogueEvent = events[key]

	for k in event.next:
		if check_condition(state, k):
			return k

	return ""
