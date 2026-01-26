class_name GdSerde


func deserialize(obj: GdSerde, dict: Dictionary) -> bool:
	var ok := true
	for prop in _get_obj_prop_list(self):
		if dict.has(prop.name):
			obj.set(prop.name, dict[prop.name])
		else:
			ok = false
	return ok


# Private Static Members

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
		if prop_filter.size() > 0 and not prop_filter.has(item.name):
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
		var t:
			assert(false, str("Unhandled type: ", type_string(t), " - ", str(value)))
			return str(value)
