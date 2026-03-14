class_name gdserde

class Result:
	var value: Variant
	var err: String


	func _init(value_: Variant, err_: String) -> void:
		value = value_
		err = err_


	static func ok(value: Variant) -> Result:
		return Result.new(value, "")


	static func fail(...args: Array) -> Result:
		return Result.new(null, str.callv(args))


class Spec:
	var type: Variant.Type
	var factory: Callable
	var sub_spec: Spec
	var fields: Array[Field]


	func _init(type_: Variant.Type) -> void:
		type = type_


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
		var value: Variant = obj.get(item.name)

		arr.push_back(Field.native(name, type))
	return arr


static func _get_obj_fields(obj: Object) -> Array[Field]:
	# TODO: cache
	return _create_obj_fields(obj)


static func deserialize_spec(spec: Spec, variant: Variant) -> Result:
	match spec.type:
		TYPE_OBJECT:
			if variant is not Object:
				return Result.fail("expected Object, got: ", variant)
			assert(spec.factory, "factory required")
			var obj: Object = spec.factory.call()
			return deserialize_object(obj, variant)
		TYPE_ARRAY:
			if variant is not Array:
				return Result.fail("expected Array, got: ", variant)
			# TODO
			return Result.ok([])
		TYPE_DICTIONARY:
			if variant is not Dictionary:
				return Result.fail("expected Dictionary, got: ", variant)
			# TODO
			return Result.ok({ })
		_:
			return Result.ok(variant)


static func deserialize_object(obj: Object, variant: Variant) -> Result:
	if variant is not Dictionary:
		return Result.fail("expected Dictionary, got: ", type_string(typeof(variant)))
	var dict: Dictionary = variant

	for field: Field in _get_obj_fields(obj):
		if dict.has(field.name):
			var res := deserialize_spec(field.spec, dict[field.name])
			if res.err:
				return Result.fail("field '", field.name, "' parse error: ", res.err)
			obj.set(field.name, res.value)
		elif not field.is_optional:
			return Result.fail("field '", field.name, "' missing from dict: ", dict)

	return Result.ok(obj)


static func serialize(value: Variant) -> Variant:
	if value is Object:
		var obj: Object = value
		return serialize_object(obj)

	return value


static func serialize_object(obj: Object) -> Dictionary:
	var dict := { }
	for field: Field in _get_obj_fields(obj):
		dict[field.name] = serialize(obj.get(field.name))
	return dict

# Tests


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
	assert(value.my_str == "foobar")


class _TestArrayField:
	var strings: Array[String]
	var objects: Array[_TestSimpleObj]


static func _test_array_field() -> void:
	var variant: Variant = {
		"strings": ["foo", "bar"],
		"objects": [{ "my_int": 55, "my_str": "embedded" }],
	}


static func _static_init() -> void:
	if OS.is_debug_build():
		_tests()


static func _tests() -> void:
	_test_simple_obj_deser()
	print("gdserde tests PASSED")
