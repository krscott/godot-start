class_name Type

const _TYPE_NAME_VARNAME := &"type_name"
const _TYPE_DEF_VARNAME := &"type_def"

static var _field_list_cache := {
	&"Node3D": [Field.implicit(&"transform")],
}

var native_type: Variant.Type
var object_class: GDScript
## Collection element type
var element_type: Type
## Dictionary key type
var key_type: Variant.Type
## Allow missing field on deserialization
var is_optional := false


static func implicit() -> Type:
	var t := Type.new()
	t.native_type = TYPE_NIL
	return t


static func native(native_type_: Variant.Type) -> Type:
	var t := Type.new()
	t.native_type = native_type_
	return t


static func object(object_class_: GDScript) -> Type:
	var t := Type.new()
	t.native_type = TYPE_OBJECT
	t.object_class = object_class_
	return t


static func array(element_type_: Type) -> Type:
	var t := Type.new()
	t.native_type = TYPE_ARRAY
	t.element_type = element_type_
	return t


static func dict(key_type_: Variant.Type, element_type_: Type) -> Type:
	var t := Type.new()
	t.native_type = TYPE_DICTIONARY
	t.element_type = element_type_
	t.key_type = key_type_
	return t


func optional() -> Type:
	is_optional = true
	return self


class Field:
	var name: StringName
	var type: Type


	func _init(name_: StringName, type_: Type) -> void:
		name = name_
		type = type_


	static func implicit(name_: StringName) -> Field:
		return Field.new(name_, Type.implicit())


	static func native(name_: StringName, native_type: Variant.Type) -> Field:
		return Field.new(name_, Type.native(native_type))


	func pretty_str(obj: Object) -> String:
		return str(util.get_or_default(obj, _TYPE_NAME_VARNAME, &"??"), ".", name)


static func _create_obj_fields(obj: Object) -> Array[Field]:
	var type_def: Variant = obj.get(_TYPE_DEF_VARNAME)
	var fields: Array[Field] = []

	if type_def:
		var fields_dict: Dictionary = type_def
		for name: String in fields_dict:
			var type: Type = fields_dict[name]
			if not type.native_type:
				type.native_type = typeof(obj.get(name)) as Variant.Type
			fields.push_back(Field.new(name, type))
	else:
		for item in obj.get_property_list():
			var name: String = item["name"]
			match name:
				"RefCounted", "script", "Script Variables", "__meta__", "Built-in script":
					continue

			var native_type: Variant.Type = item["type"]
			fields.push_back(Field.native(name, native_type))

	# Sanity check
	if OS.is_debug_build():
		for field in fields:
			var name := field.name
			var type := field.type
			var default_value: Variant = obj.get(name)
			assert(
				util.has_member_nullable(obj, name),
				str(
					"Missing field '",
					field.pretty_str(obj),
					"', actual fields: ",
					util.get_field_names(obj),
				),
			)
			assert(
				default_value != null,
				str(
					"Field '",
					field.pretty_str(obj),
					"', is null (even optionals cannot be null--add a default object)",
				),
			)
			assert(
				type.native_type == typeof(default_value),
				str(
					field.pretty_str(obj),
					" ",
					util.msg_unexpected_type(type.native_type, default_value),
				),
			)

	return fields


static func get_fields(obj: Object) -> Array[Field]:
	assert(obj)
	var fields: Array[Field] = []

	if obj.get_script():
		var type_name: StringName = obj.get(_TYPE_NAME_VARNAME)
		if type_name:
			if _field_list_cache.has(type_name):
				var arr: Array = _field_list_cache[type_name]
				fields.assign(arr)
			else:
				fields = _create_obj_fields(obj)
				_field_list_cache[type_name] = fields
		else:
			push_warning("Unoptimized class: ", obj)
			fields = _create_obj_fields(obj)

	else:
		var obj_class := StringName(obj.get_class())
		while obj_class and not _field_list_cache.has(obj_class):
			obj_class = ClassDB.get_parent_class(obj_class)
		if _field_list_cache.has(obj_class):
			var arr: Array = _field_list_cache[obj_class]
			fields.assign(arr)
		else:
			assert(false, str("Unhandled class, add to gdserde._field_list_cache: ", obj_class))
			fields = _create_obj_fields(obj)

	return fields
