class_name gdserde

static func _is_packed_array_type(type: Variant.Type) -> bool:
	match type:
		TYPE_PACKED_BYTE_ARRAY, \
		TYPE_PACKED_INT32_ARRAY, \
		TYPE_PACKED_INT64_ARRAY, \
		TYPE_PACKED_FLOAT32_ARRAY, \
		TYPE_PACKED_FLOAT64_ARRAY, \
		TYPE_PACKED_STRING_ARRAY, \
		TYPE_PACKED_VECTOR2_ARRAY, \
		TYPE_PACKED_VECTOR3_ARRAY, \
		TYPE_PACKED_COLOR_ARRAY, \
		TYPE_PACKED_VECTOR4_ARRAY:
			return true
		_:
			return false


static func _get_packed_element_type(type: Variant.Type) -> Variant.Type:
	match type:
		TYPE_PACKED_BYTE_ARRAY:
			return TYPE_INT
		TYPE_PACKED_INT32_ARRAY:
			return TYPE_INT
		TYPE_PACKED_INT64_ARRAY:
			return TYPE_INT
		TYPE_PACKED_FLOAT32_ARRAY:
			return TYPE_FLOAT
		TYPE_PACKED_FLOAT64_ARRAY:
			return TYPE_FLOAT
		TYPE_PACKED_STRING_ARRAY:
			return TYPE_STRING
		TYPE_PACKED_VECTOR2_ARRAY:
			return TYPE_VECTOR2
		TYPE_PACKED_VECTOR3_ARRAY:
			return TYPE_VECTOR3
		TYPE_PACKED_COLOR_ARRAY:
			return TYPE_COLOR
		TYPE_PACKED_VECTOR4_ARRAY:
			return TYPE_VECTOR4
		_:
			assert(false)
			return TYPE_NIL


static func _get_packed_array_by_type(type: Variant.Type) -> Variant:
	match type:
		TYPE_PACKED_BYTE_ARRAY:
			return PackedByteArray()
		TYPE_PACKED_INT32_ARRAY:
			return PackedInt32Array()
		TYPE_PACKED_INT64_ARRAY:
			return PackedInt64Array()
		TYPE_PACKED_FLOAT32_ARRAY:
			return PackedFloat32Array()
		TYPE_PACKED_FLOAT64_ARRAY:
			return PackedFloat64Array()
		TYPE_PACKED_STRING_ARRAY:
			return PackedStringArray()
		TYPE_PACKED_VECTOR2_ARRAY:
			return PackedVector2Array()
		TYPE_PACKED_VECTOR3_ARRAY:
			return PackedVector3Array()
		TYPE_PACKED_COLOR_ARRAY:
			return PackedColorArray()
		TYPE_PACKED_VECTOR4_ARRAY:
			return PackedVector4Array()
		_:
			assert(false)
			return null


static func deserialize_spec(spec: Type, variant: Variant) -> Result:
	match spec.native_type:
		TYPE_OBJECT:
			assert(spec.object_class, "object_class required")
			if variant is not Dictionary:
				return Result.fail(util.msg_unexpected_type(TYPE_DICTIONARY, variant))
			var obj: Object = spec.object_class.new()
			return deserialize_object(obj, variant)
		TYPE_ARRAY:
			assert(spec.element_type, "element_type required")
			if variant is not Array:
				return Result.fail(util.msg_unexpected_type(TYPE_ARRAY, variant))
			var arr: Array = variant
			var out := []
			for i in arr.size():
				var res := deserialize_spec(spec.element_type, arr[i])
				if res.err:
					return res.context("index ", i)
				out.push_back(res.value)
			return Result.ok(out)
		TYPE_DICTIONARY:
			if variant is not Dictionary:
				return Result.fail(util.msg_unexpected_type(TYPE_DICTIONARY, variant))
			var dict: Dictionary = variant
			var out := { }
			for k: Variant in dict:
				if typeof(k) != spec.key_type:
					return Result.fail(util.msg_unexpected_type(spec.key_type, k))
				var res := deserialize_spec(spec.element_type, dict[k])
				if res.err:
					return res.context("key=", var_to_str(k), " >")
				out[k] = res.value
			return Result.ok(out)
		_:
			if _is_packed_array_type(spec.native_type) and variant is Array:
				var packed_element_type := _get_packed_element_type(spec.native_type)
				var arr: Array = variant
				var out: Variant = _get_packed_array_by_type(spec.native_type)
				for i in arr.size():
					var res := deserialize_spec(Type.native(packed_element_type), arr[i])
					if res.err:
						return res.context("index ", i)
					@warning_ignore("unsafe_method_access") # `out` is any PackedArray
					out.push_back(res.value)
				return Result.ok(out)

			if spec.native_type != typeof(variant):
				return Result.fail(util.msg_unexpected_type(spec.native_type, variant))

			return Result.ok(variant)


## (T, any) -> Result<T>
static func deserialize_object(obj: Object, variant: Variant) -> Result:
	if obj.has_method(&"gdserde_deserialize"):
		return obj.call(&"gdserde_deserialize", variant)

	if variant is not Dictionary:
		return Result.fail(util.msg_unexpected_type(TYPE_DICTIONARY, variant))
	var dict: Dictionary = variant

	for field in Type.get_fields(obj):
		if dict.has(field.name):
			var res := deserialize_spec(field.type, dict[field.name])
			if res.err:
				return res.context(field.pretty_str(obj), " >")

			assert(util.has_member(obj, field.name))
			var target: Variant = obj.get(field.name)
			if target is Array and res.value is Array:
				var target_arr: Array = target
				var res_arr: Array = res.value
				target_arr.assign(res_arr)
			else:
				obj.set(field.name, res.value)
				# This will fail if not exactly the same type
				# e.g. Array != Array[int], even if both are array of ints
				assert(obj.get(field.name) == res.value, str(obj.get(field.name), " ", res.value))
		elif not field.type.is_optional:
			return Result.fail(field.pretty_str(obj), " field name missing from dict: ", dict)

	return Result.ok(obj)


static func serialize(value: Variant) -> Variant:
	if value is Object:
		var obj: Object = value
		return serialize_object(obj)

	if value is Array:
		var out := []
		for x: Variant in value:
			out.push_back(serialize(x))
		return out

	if value is Dictionary:
		var out := { }
		for k: Variant in value:
			out[serialize(k)] = serialize(value[k])
		return out

	return value


static func serialize_object(obj: Object) -> Dictionary:
	if obj.has_method(&"gdserde_serialize"):
		return obj.call(&"gdserde_serialize")

	var dict := { }
	for field in Type.get_fields(obj):
		dict[field.name] = serialize(obj.get(field.name))
	return dict

#########
# Tests #
#########


class _TestSimpleObj:
	const type_name := &"_TestSimpleObj"
	var my_int: int
	var my_str: String


static func _test_simple_obj_deser() -> void:
	var variant: Variant = {
		"my_int": 5,
		"my_str": "foobar",
	}
	var obj := _TestSimpleObj.new()
	var res := deserialize_object(obj, variant)
	assert(not res.err, res.error_message())
	assert(obj.my_int == 5)
	assert(obj.my_str == "foobar")


static func _test_simple_obj_ser() -> void:
	var obj := _TestSimpleObj.new()
	obj.my_int = 99
	obj.my_str = "hello"
	var value := serialize_object(obj)
	assert(value.my_int == 99)
	assert(value.my_str == "hello")


class _TestArrayField:
	const type_name := &"_TestArrayField"


	# TODO: Convert type_def to static func
	static func type_def() -> Dictionary:
		return {
			"strings": Type.array(Type.native(TYPE_STRING)),
			"objects": Type.array(Type.object(_TestSimpleObj)),
		}


	var strings: Array[String]
	var objects: Array[_TestSimpleObj]


static func _test_array_field_deser() -> void:
	var variant: Variant = {
		"strings": ["foo", "bar"],
		"objects": [{ "my_int": 11, "my_str": "first" }, { "my_int": 22, "my_str": "second" }],
	}

	var obj := _TestArrayField.new()
	var res := deserialize_object(obj, variant)
	assert(not res.err, res.error_message())
	assert(obj.strings[0] == "foo")
	assert(obj.strings[1] == "bar")
	assert(obj.strings.size() == 2)
	var first: _TestSimpleObj = obj.objects[0]
	assert(first.my_str == "first")
	var second: _TestSimpleObj = obj.objects[1]
	assert(second.my_str == "second")
	assert(obj.objects.size() == 2)


static func _test_array_field_ser() -> void:
	var a := _TestSimpleObj.new()
	a.my_int = 123
	a.my_str = "oatmeal"
	var b := _TestSimpleObj.new()
	b.my_int = 123
	b.my_str = "kirby"

	var obj := _TestArrayField.new()
	obj.strings = ["one", "two"]
	obj.objects = [a, b]

	var value := serialize_object(obj)
	assert(value["strings"][0] == "one")
	assert(value["strings"][1] == "two")
	assert(len(value["strings"]) == 2)
	assert(value["objects"][0]["my_str"] == "oatmeal")
	assert(value["objects"][1]["my_str"] == "kirby")
	assert(len(value["objects"]) == 2)
	assert(typeof(value["objects"][1]) == TYPE_DICTIONARY)


class _TestDictField:
	const type_name := &"_TestDictField"


	static func type_def() -> Dictionary:
		return {
			&"integer_names": Type.dict(TYPE_INT, Type.native(TYPE_STRING)),
			&"simple_lookup": Type.dict(TYPE_STRING, Type.object(_TestSimpleObj)),
		}


	var integer_names: Dictionary
	var simple_lookup: Dictionary


static func _test_dict_field_deser() -> void:
	var variant: Variant = {
		"integer_names": {
			42: "forty-two",
			-10: "negative ten",
		},
		"simple_lookup": {
			"alpha": { "my_int": 11, "my_str": "eleven" },
			"beta": { "my_int": 22, "my_str": "twenty-two" },
		},
	}

	var obj := _TestDictField.new()
	var res := deserialize_object(obj, variant)
	assert(not res.err, res.error_message())
	assert(obj.integer_names[42] == "forty-two")
	assert(obj.integer_names[-10] == "negative ten")
	var a: _TestSimpleObj = obj.simple_lookup["alpha"]
	assert(a.my_str == "eleven")
	var b: _TestSimpleObj = obj.simple_lookup["beta"]
	assert(b.my_str == "twenty-two")


static func _test_dict_field_ser() -> void:
	var a := _TestSimpleObj.new()
	a.my_int = -99
	a.my_str = "qux"
	var b := _TestSimpleObj.new()
	b.my_int = 99
	b.my_str = "cruft"

	var obj := _TestDictField.new()
	obj.integer_names = {
		0x11: "onety-one",
		0xF5: "fleventy-five",
	}
	obj.simple_lookup = {
		"quebec": a,
		"charlie": b,
	}

	var value := serialize_object(obj)
	assert(value["integer_names"][0xF5] == "fleventy-five")
	assert(value["simple_lookup"]["charlie"]["my_int"] == 99)
	assert(value["simple_lookup"]["charlie"] is Dictionary)


class _TestOptionalField:
	const type_name := &"_TestOptionalField"


	static func type_def() -> Dictionary:
		return {
			&"my_int": Type.implicit().optional(),
			&"my_str": Type.implicit().optional(),
		}


	var my_int: int = 10
	var my_str: String = "nothing"


static func _test_optional_deser() -> void:
	if true:
		var variant := { "my_int": 5 }
		var obj := _TestOptionalField.new()
		var res := deserialize_object(obj, variant)
		assert(not res.err, res.error_message())
		assert(obj.my_int == 5)
		assert(obj.my_str == "nothing")

	if true:
		var variant := { "my_str": "something" }
		var obj := _TestOptionalField.new()
		var res := deserialize_object(obj, variant)
		assert(not res.err, res.error_message())
		assert(obj.my_int == 10)
		assert(obj.my_str == "something")


class _TestPackedArrayField:
	const type_name := &"_TestPackedArrayField"


	static func type_def() -> Dictionary:
		return {
			&"vectors": Type.implicit(),
			&"sentences": Type.array(Type.native(TYPE_PACKED_STRING_ARRAY)),
		}


	var vectors: PackedVector2Array
	var sentences: Array[PackedStringArray]


static func _test_packed_array_deser() -> void:
	if true:
		# JSON-compatible types
		var variant := {
			"vectors": [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT],
			"sentences": [["Run", "and", "jump"], ["Duck", "and", "dodge"]],
		}
		var obj := _TestPackedArrayField.new()
		var res := deserialize_object(obj, variant)
		assert(not res.err, res.error_message())
		assert(obj.vectors[3] == Vector2.RIGHT)
		assert(obj.sentences[1][2] == "dodge")
		assert(typeof(obj.sentences[1]) == TYPE_PACKED_STRING_ARRAY)

	if true:
		# native packed array types
		var variant := {
			"vectors": PackedVector2Array([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]),
			"sentences": [
				PackedStringArray(["Run", "and", "jump"]),
				PackedStringArray(["Duck", "and", "dodge"]),
			],
		}
		var obj := _TestPackedArrayField.new()
		var res := deserialize_object(obj, variant)
		assert(not res.err, res.error_message())
		assert(obj.vectors[3] == Vector2.RIGHT)
		assert(obj.sentences[1][2] == "dodge")
		assert(typeof(obj.sentences[1]) == TYPE_PACKED_STRING_ARRAY)


static func _test_node3d() -> void:
	var node1 := Marker3D.new() # Subclass of Node3D
	node1.transform.origin = Vector3(1, 2, 3)

	var variant: Variant = serialize(node1)

	var node2 := Marker3D.new()
	var res := deserialize_object(node2, variant)
	assert(not res.err, res.error_message())
	assert(node2.transform.origin == Vector3(1, 2, 3))

	node1.free()
	node2.free()


static func _static_init() -> void:
	if OS.is_debug_build():
		_tests()


static func _tests() -> void:
	_test_simple_obj_deser()
	_test_simple_obj_ser()
	_test_array_field_deser()
	_test_array_field_ser()
	_test_dict_field_deser()
	_test_dict_field_ser()
	_test_optional_deser()
	_test_packed_array_deser()
	_test_node3d()
	print("gdserde tests PASSED")
