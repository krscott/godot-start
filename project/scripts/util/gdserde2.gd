class_name gdserde

class Result:
	var value: Variant
	var err: String


	func _init(value_: Variant, err_: String) -> void:
		value = value_
		err = err_


	static func ok(value_: Variant) -> Result:
		return Result.new(value_, "")


	static func fail(...args: Array) -> Result:
		var msg: String = str.callv(args)
		return Result.new(null, msg)


	static func unexpected_type(expected_type: Variant.Type, actual_value: Variant) -> Result:
		var msg := str("expected ", type_string(expected_type), ", got ", type_string(typeof(actual_value)), ": ", actual_value)
		return Result.new(null, msg)


class Spec:
	var type: Variant.Type
	var factory: Callable
	var inner: Spec
	var key_type: Variant.Type


	func _init(type_: Variant.Type) -> void:
		type = type_


	static func native(type_: Variant.Type) -> Spec:
		return Spec.new(type_)


	static func object(factory_: Callable) -> Spec:
		var spec := Spec.new(TYPE_OBJECT)
		spec.factory = factory_
		return spec


	static func array(inner_: Spec) -> Spec:
		var spec := Spec.new(TYPE_ARRAY)
		spec.inner = inner_
		return spec


	static func dict(key_type_: Variant.Type, inner_: Spec) -> Spec:
		var spec := Spec.new(TYPE_DICTIONARY)
		spec.inner = inner_
		spec.key_type = key_type_
		return spec


class Field:
	var name: StringName
	var spec: Spec
	var is_optional := false


	func _init(name_: StringName, spec_: Spec) -> void:
		name = name_
		spec = spec_


	static func native(name_: StringName, type: Variant.Type) -> Field:
		return Field.new(name_, Spec.new(type))


static func _create_obj_fields(obj: Object) -> Array[Field]:
	var arr: Array[Field] = []
	for item in obj.get_property_list():
		var name: String = item["name"]
		match name:
			"RefCounted", "script", "Script Variables", "__meta__", "Built-in script":
				continue

		var type: Variant.Type = item["type"]
		#var value: Variant = obj.get(name)

		if obj.has_method(&"gdserde_fields"):
			var fields: Array[Field] = obj.call(&"gdserde_fields")
			for field: Field in fields:
				if field.name == name:
					arr.push_back(field)
					break
		else:
			arr.push_back(Field.native(name, type))
	return arr


static func _get_obj_fields(obj: Object) -> Array[Field]:
	# TODO: cache
	return _create_obj_fields(obj)


static func deserialize_spec(spec: Spec, variant: Variant) -> Result:
	match spec.type:
		TYPE_OBJECT:
			assert(spec.factory, "factory required")
			if variant is not Dictionary:
				return Result.unexpected_type(TYPE_DICTIONARY, variant)
			var obj: Object = spec.factory.call()
			return deserialize_object(obj, variant)
		TYPE_ARRAY:
			assert(spec.inner, "inner required")
			if variant is not Array:
				return Result.unexpected_type(TYPE_ARRAY, variant)
			var arr: Array = variant
			var out := []
			for i in arr.size():
				var res := deserialize_spec(spec.inner, arr[i])
				if res.err:
					return Result.fail("index ", i, " ", res.err)
				out.push_back(res.value)
			return Result.ok(out)
		TYPE_DICTIONARY:
			if variant is not Dictionary:
				return Result.unexpected_type(TYPE_DICTIONARY, variant)
			var dict: Dictionary = variant
			var out := { }
			for k: Variant in dict:
				if typeof(k) != spec.key_type:
					return Result.unexpected_type(spec.key_type, k)
				var res := deserialize_spec(spec.inner, dict[k])
				if res.err:
					return Result.fail("key ", k, " ", res.err)
				out[k] = res.value
			return Result.ok(out)
		_:
			if spec.type != typeof(variant):
				return Result.unexpected_type(spec.type, variant)
			return Result.ok(variant)


static func deserialize_object(obj: Object, variant: Variant) -> Result:
	if variant is not Dictionary:
		return Result.unexpected_type(TYPE_DICTIONARY, variant)
	var dict: Dictionary = variant

	for field: Field in _get_obj_fields(obj):
		if dict.has(field.name):
			var res := deserialize_spec(field.spec, dict[field.name])
			if res.err:
				return Result.fail("field '", field.name, "' ", res.err)
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
		elif not field.is_optional:
			return Result.fail("field '", field.name, "' missing from dict: ", dict)

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
	var dict := { }
	for field: Field in _get_obj_fields(obj):
		dict[field.name] = serialize(obj.get(field.name))
	return dict

#########
# Tests #
#########


class _TestSimpleObj:
	var my_int: int
	var my_str: String


static func _test_simple_obj_deser() -> void:
	var variant: Variant = {
		"my_int": 5,
		"my_str": "foobar",
	}
	var obj := _TestSimpleObj.new()
	var res := deserialize_object(obj, variant)
	assert(not res.err, res.err)
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
	static func gdserde_fields() -> Array[Field]:
		return [
			Field.new(&"strings", Spec.array(Spec.native(TYPE_STRING))),
			Field.new(&"objects", Spec.array(Spec.object(_TestSimpleObj.new))),
		]


	var strings: Array[String]
	var objects: Array[_TestSimpleObj]


static func _test_array_field_deser() -> void:
	var variant: Variant = {
		"strings": ["foo", "bar"],
		"objects": [{ "my_int": 11, "my_str": "first" }, { "my_int": 22, "my_str": "second" }],
	}

	var obj := _TestArrayField.new()
	var res := deserialize_object(obj, variant)
	assert(not res.err, res.err)
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
	static func gdserde_fields() -> Array[Field]:
		return [
			Field.new(&"integer_names", Spec.dict(TYPE_INT, Spec.native(TYPE_STRING))),
			Field.new(&"simple_lookup", Spec.dict(TYPE_STRING, Spec.object(_TestSimpleObj.new))),
		]


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
	assert(not res.err, res.err)
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
	print("gdserde tests PASSED")
