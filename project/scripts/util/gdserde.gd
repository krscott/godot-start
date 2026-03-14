## Utilities for serializing/deserializng Godot Objects
## NOTE: Technically, this is not full serializing/deserializing--it is just
##       handling conversion to/from Variant, which can then be converted to
##       JSON, etc.
class_name GdSerde

static var _property_list_cache := { }


class GdSerdeProperty:
	var name: StringName
	var type: Variant.Type
	var optional: bool
	## (original: Variant, value: Variant) -> [Variant, Error]
	var deser_func: Callable


	func _to_string() -> String:
		return "GdSerdeProperty<%s: %s>" % [name, type_string(type)]


static func _create_property_list(
		obj: Object,
		prop_filter: Variant,
		prop_optionals: Array,
) -> Array[GdSerdeProperty]:
	var out: Array[GdSerdeProperty] = []
	for item in obj.get_property_list():
		var deser_func := deserialize
		
		if prop_filter is Array:
			var pf_arr: Array = prop_filter
			if not pf_arr.has(item.name):
				continue
		elif prop_filter is Dictionary:
			var pf_dict: Dictionary = prop_filter
			if not pf_dict.has(item.name):
				continue
			deser_func = pf_dict[item.name]

		match item.name:
			"RefCounted", "script", "Script Variables", "__meta__", "Built-in script":
				continue

		var name: String = item.name
		var type: Variant.Type = item.type
		if not name.ends_with(".gd"):
			var prop := GdSerdeProperty.new()
			prop.name = name
			prop.type = type
			prop.deser_func = deser_func
			prop.optional = prop_optionals.has(name)
			out.push_back(prop)
	return out


static func _get_obj_prop_list(obj: Object) -> Array[GdSerdeProperty]:
	var gdserde_class := &""
	## Array[StringName] | Dictionary[StringName, Callable]
	var prop_filter: Variant
	var prop_list: Array[GdSerdeProperty]
	var prop_optionals: Array = []

	if obj.get_script():
		if util.has_member(obj, &"gdserde_class"):
			gdserde_class = obj.get(&"gdserde_class")

			if util.has_member(obj, &"gdserde_props"):
				prop_filter = obj.get(&"gdserde_props")
			elif obj.get_class() != "RefCounted":
				assert(false, str("Object must define gdserde_props: ", obj))
			else:
				prop_filter = null
			
			if util.has_member(obj, &"gdserde_optional"):
				prop_optionals = obj.get(&"gdserde_optional")

	elif obj is Node3D:
		gdserde_class = &"Node3D"
		prop_filter = [&"transform"]

	if gdserde_class:
		if _property_list_cache.has(gdserde_class):
			prop_list = _property_list_cache[gdserde_class]
		else:
			prop_list = _create_property_list(obj, prop_filter, prop_optionals)
			_property_list_cache[gdserde_class] = prop_list
			#print_debug("GdSerde: cached ", gdserde_class, " props ", prop_list)
	else:
		assert(
			false,
			"Object %s not optimized for serialization, set gdserde_class" %
			[str(obj)],
		)
		prop_list = _create_property_list(obj, [], [])

	assert(prop_list)
	return prop_list


static func serialize(value: Variant) -> Variant:
	if value is Object:
		var obj: Object = value
		if obj.has_method(&"gdserde_serialize"):
			return obj.call(&"gdserde_serialize")

		var out := { }
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
			if dict.has(prop.name):
				match prop.deser_func.call(obj.get(prop.name), dict[prop.name]):
					[var x, OK]:
						obj.set(prop.name, x)
					[var x, var err]:
						assert(err is Error)
						return [x, err]
			elif not prop.optional:
				return _err()
		return _ok(obj)

	return _ok(value)


static func deserialize_object(obj: Object, value: Dictionary) -> Error:
	match deserialize(obj, value):
		[_, var err]:
			return err
	assert(false)
	return ERR_BUG


static func deserialize_object_array(
	arr: Array, value: Array, factory: Callable
) -> Error:
	var err := OK
	arr.clear()
	for data: Variant in value:
		if data is not Dictionary:
			err = ERR_PARSE_ERROR
			continue
		var dict: Dictionary = data
			
		var obj: Object = factory.call()
		var err2 := deserialize_object(obj, dict)
		if err2:
			err = err2
		arr.push_back(obj)
	return err

## Same as deserialize_object_array, but accepts Variant
static func deserialize_object_array_var(
	arr: Array, value: Variant, factory: Callable
) -> Array:
	arr.clear()
	
	if value is not Array:
		return [arr, ERR_PARSE_ERROR]

	var input_arr: Array = value
	return [
		arr, 
		GdSerde.deserialize_object_array(arr, input_arr, factory)
	]

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
