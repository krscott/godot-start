class_name GdSerde

class GdSerdeResult:
	var value: Variant
	var err: bool

	func _init(value_: Variant, err_: bool) -> void:
		value = value_
		err = err_

static func _ok(value: Variant) -> GdSerdeResult:
	return GdSerdeResult.new(value, false)

static func _err() -> GdSerdeResult:
	return GdSerdeResult.new(null, true)

class GdSerdeProperty:
	var name: StringName
	var type: Variant.Type

	func _init(name_: StringName, type_: Variant.Type) -> void:
		name = name_
		type = type_

	func _to_string() -> String:
		return "GdSerdeProperty<%s: %s>" % [name, type_string(type)]

static var _property_list_cache := {}

static func _create_property_list(
	obj: Object,
	prop_filter: Array
) -> Array[GdSerdeProperty]:
	var out: Array[GdSerdeProperty] = []
	for item in obj.get_property_list():
		if prop_filter and not prop_filter.has(item.name):
			continue

		match item.name:
			"RefCounted", "script", "Script Variables", "__meta__":
				continue

		var name: String = item.name
		var type: Variant.Type = item.type
		if not name.ends_with(".gd"):
			#print(str(item))
			out.push_back(GdSerdeProperty.new(name, type))
	return out

static func _get_obj_prop_list(obj: Object) -> Array[GdSerdeProperty]:
	var prop_list: Array[GdSerdeProperty]

	if util.has_member(obj, &"gdserde_class"):
		var type: StringName = obj.get(&"gdserde_class")

		if _property_list_cache.has(type):
			prop_list = _property_list_cache[type]
		else:
			var prop_filter: Array
			if util.has_member(obj, &"gdserde_props"):
				prop_filter = obj.get(&"gdserde_props")
			elif obj.get_class() != "RefCounted":
				assert(false, str("Object must define gdserde_props: ", obj))
			else:
				prop_filter = []
			prop_list = _create_property_list(obj, prop_filter)
			_property_list_cache[type] = prop_list
			print_debug("GdSerde: cached ", type, " props ", prop_list)
	else:
		assert(
			false,
			"Object %s not optimized for serialization, set gdserde_class" %
			[str(obj)]
		)
		prop_list = _create_property_list(obj, [])

	assert(prop_list)
	return prop_list


static func _serialize_object(obj: Object) -> Dictionary:
	if obj.has_method(&"gdserde_serialize"):
		return obj.call(&"gdserde_serialize")
	else:
		var out := {}
		for prop in _get_obj_prop_list(obj):
			out[prop.name] = serialize(obj.get(prop.name))
		return out

static func _deserialize_object(original: Object, value: Dictionary) -> GdSerdeResult:
	if original.has_method(&"gdserde_deserialize"):
		return original.call(&"gdserde_deserialize", value)
	else:
		for prop in _get_obj_prop_list(original):
			var res := deserialize(original.get(prop.name), value[prop.name])
			if res.err:
				return res
			#print("Setting ", prop.name)
			original.set(prop.name, res.value)
		return _ok(original)

static func serialize(value: Variant) -> Variant:
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			# JSON primitive types
			return value
		TYPE_ARRAY, TYPE_DICTIONARY:
			# Assuming contains only primitives
			return value
		TYPE_OBJECT:
			var obj: Object = value
			return _serialize_object(obj)
		TYPE_VECTOR2:
			return [value.x, value.y]
		TYPE_VECTOR3:
			return [value.x, value.y, value.z]
		TYPE_TRANSFORM3D:
			var t: Transform3D = value
			return [
				t.basis.x.x, t.basis.x.y, t.basis.x.z,
				t.basis.y.x, t.basis.y.y, t.basis.y.z,
				t.basis.z.x, t.basis.z.y, t.basis.z.z,
				t.origin.x,  t.origin.y,  t.origin.z,
			]
		TYPE_QUATERNION:
			var q: Quaternion = value
			return [q.x, q.y, q.z, q.w]
		var t:
			assert(false, str("Unhandled type: ", type_string(t), " - ", str(value)))
			return str(value)


static func deserialize(original: Variant, value: Variant) -> GdSerdeResult:
	match typeof(original):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			# JSON primitive types
			return _ok(value)
		TYPE_ARRAY, TYPE_DICTIONARY:
			# Assuming contains only primitives
			return _ok(value)
		TYPE_OBJECT:
			var value_dict: Dictionary = value
			var original_obj: Object = original
			return _deserialize_object(original_obj, value_dict)
		TYPE_VECTOR2:
			var a := _to_float_array(value, 2)
			if not a: return _err()
			return _ok(Vector2(a[0] as float, a[1] as float))
		TYPE_VECTOR3:
			var a := _to_float_array(value, 3)
			if not a: return _err()
			return _ok(Vector3(a[0], a[1], a[2]))
		TYPE_TRANSFORM3D:
			var a := _to_float_array(value, 12)
			if not a: return _err()
			return _ok(Transform3D(
				Vector3(a[ 0], a[ 1], a[ 2]),
				Vector3(a[ 3], a[ 4], a[ 5]),
				Vector3(a[ 6], a[ 7], a[ 8]),
				Vector3(a[ 9], a[10], a[11]),
			))
		TYPE_QUATERNION:
			var a := _to_float_array(value, 4)
			if not a: return _err()
			return _ok(Quaternion(a[0], a[1], a[2], a[3]))
		var t:
			assert(false, str("Unhandled type: ", type_string(t), " - ", str(value)))
			return _err()

static func _to_float_array(value: Variant, expected_size: int) -> Array[float]:
	if typeof(value) != TYPE_ARRAY:
		return []
	var arr: Array[float] = []
	for x: Variant in value:
		if x is int:
			var i: int = x
			arr.push_back(float(i))
		elif x is float:
			var f: float = x
			arr.push_back(f)
		else:
			return []
	if arr.size() != expected_size:
		return []
	return arr
