class_name DialogueEvent
const gdserde_class = &"DialogueEvent"
const gdserde_optional := [
	&"conds",
	&"speaker",
	&"text",
	&"next",
	&"choices",
]
static var gdserde_props := {
	&"conds": _deser_packed_string_array,
	&"speaker": GdSerde.deserialize,
	&"text": _deser_packed_string_array,
	&"next": _deser_packed_string_array,
	&"choices": _deser_choices,
}

class DialogChoice:
	const gdserde_class = &"DialogChoice"
	var text: String
	var next: String

var conds: PackedStringArray
var speaker: String
var text: PackedStringArray
var next: PackedStringArray
var choices: Array[DialogChoice]

static func _deser_packed_string_array(
	arr: PackedStringArray, x: Variant
) -> Array:
	var err := OK
	arr.clear()
	
	if x is String:
		util.expect_false(arr.push_back(util.as_str(x)))
	elif x is Array:
		for elem: String in x:
			util.expect_false(arr.push_back(util.as_str(elem)))
	else:
		err = ERR_PARSE_ERROR
	
	assert(err == OK)
	return [arr, err]



static func _deser_choices(arr: Array[DialogChoice], value: Variant) -> Array:
	var res := GdSerde.deserialize_object_array_var(arr, value, DialogChoice.new)
	assert(res[1] == OK)
	return res
