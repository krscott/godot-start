## Utilities for serializing/deserializng Godot Objects
## NOTE: Technically, this is not full serializing/deserializing--it is just
##       handling conversion to/from Variant, which can then be converted to
##       JSON, etc.
class_name GdSerde

static var _property_list_cache := {}

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
			out.push_back(GdSerdeProperty.new(name, type))
	return out


static func _get_obj_prop_list(obj: Object) -> Array[GdSerdeProperty]:
	var gdserde_class := &""
	var prop_filter: Array
	var prop_list: Array[GdSerdeProperty]

	if obj.get_script():
		if util.has_member(obj, &"gdserde_class"):
			gdserde_class = obj.get(&"gdserde_class")

			if util.has_member(obj, &"gdserde_props"):
				prop_filter = obj.get(&"gdserde_props")
			elif obj.get_class() != "RefCounted":
				assert(false, str("Object must define gdserde_props: ", obj))
			else:
				prop_filter = []

	elif obj is Node3D:
		gdserde_class = &"Node3D"
		prop_filter = [&"transform"]


	if gdserde_class:
		if _property_list_cache.has(gdserde_class):
			prop_list = _property_list_cache[gdserde_class]
		else:
			prop_list = _create_property_list(obj, prop_filter)
			_property_list_cache[gdserde_class] = prop_list
			#print_debug("GdSerde: cached ", gdserde_class, " props ", prop_list)
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


static func serialize_object(obj: Object) -> Dictionary:
	var dict: Dictionary = serialize(obj)
	return dict


## returns [Variant, Error]
static func deserialize(original: Variant, value: Variant) -> Array:
	if original is Object:
		var obj: Object = original
		if value is not Dictionary:
			return _err()
		var dict: Dictionary = value

		if obj.has_method(&"gdserde_deserialize"):
			var err: Error = obj.call(&"gdserde_deserialize", dict)
			return [obj, err]

		for prop in _get_obj_prop_list(obj):
			match deserialize(obj.get(prop.name), dict[prop.name]):
				[var x, OK]:
					obj.set(prop.name, x)
				var res:
					return res
		return _ok(obj)

	return _ok(value)


static func deserialize_object(obj: Object, value: Dictionary) -> Error:
	match deserialize(obj, value):
		[_, var err]:
			return err
	assert(false)
	return ERR_BUG


static func clone_object(to: Object, from: Object) -> Error:
	var dict := serialize_object(from)
	return deserialize_object(to, dict)


## returns [null, Error]
static func _err(err: Error = FAILED) -> Array:
	assert(err != OK)
	return [null, err]


## returns [Variant, OK]
static func _ok(value: Variant) -> Variant:
	return [value, OK]
