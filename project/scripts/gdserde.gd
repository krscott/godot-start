class_name GdSerde

static var _property_list_cache := {}

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


static func serialize(value: Variant) -> Variant:
	if value is Object:
		var obj: Object = value
		if obj.has_method(&"gdserde_serialize"):
			return obj.call(&"gdserde_serialize")

		var out := {}
		for prop in _get_obj_prop_list(obj):
			out[prop.name] = serialize(obj.get(prop.name))
		return out

	return value


static func deserialize(original: Variant, value: Variant) -> GdSerdeResult:
	if original is Object:
		var obj: Object = original
		if value is not Dictionary:
			return _err()
		var dict: Dictionary = value

		if obj.has_method(&"gdserde_deserialize"):
			return obj.call(&"gdserde_deserialize", dict)

		for prop in _get_obj_prop_list(obj):
			var res := deserialize(obj.get(prop.name), dict[prop.name])
			if res.err:
				return res
			obj.set(prop.name, res.value)
		return _ok(obj)

	return _ok(value)
