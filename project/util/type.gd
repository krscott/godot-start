class_name Type

const _TYPE_NAME_VARNAME := &"type_name"
const _TYPE_DEF_FUNCNAME := &"type_def"

static var _field_list_cache := {
	&"Node3D": [Field.native(&"transform", TYPE_TRANSFORM3D)],
}

var native_type: Variant.Type
var object_class: GDScript
## Collection element type
var element_type: Type
## Dictionary key type
var key_type: Variant.Type
## Allow missing field on deserialization
var is_optional := false


func _copy() -> Type:
	var t := Type.new()
	t.native_type = native_type
	t.object_class = object_class
	t.element_type = element_type
	t.key_type = key_type
	t.is_optional = is_optional
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


static func optional(type_: Type = null) -> Type:
	if not type_:
		type_ = Type.new()
	else:
		type_ = type_._copy()
	type_.is_optional = true
	return type_


func is_implicitly_defined() -> bool:
	return native_type == TYPE_NIL


class Field:
	var name: StringName
	var type: Type


	func _init(name_: StringName, type_: Type) -> void:
		name = name_
		type = type_


	static func native(name_: StringName, native_type: Variant.Type) -> Field:
		return Field.new(name_, Type.native(native_type))


	func pretty_str(obj: Object) -> String:
		return str(
			util.get_or_default(obj, _TYPE_NAME_VARNAME, obj.get_class()),
			".",
			name,
		)


static func _create_obj_fields(obj: Object) -> Array[Field]:
	var fields: Array[Field] = []

	if obj.has_method(_TYPE_DEF_FUNCNAME):
		var fields_dict: Dictionary = obj.call(_TYPE_DEF_FUNCNAME)
		for name: String in fields_dict:
			var type: Type = fields_dict[name]
			if not type:
				type = Type.new()
			if not type.native_type:
				type.native_type = typeof(obj.get(name)) as Variant.Type
			fields.push_back(Field.new(name, type))
	else:
		var props := obj.get_property_list()
		var i := 0
		while i < props.size():
			if props[i].name == "script":
				i += 1
				break
			i += 1

		i += 1 # Skip name of script

		while i < props.size():
			var name: String = props[i].name
			if not name.contains("/") and obj.get(name) is not Node:
				var native_type_: Variant.Type = props[i].type
				print("field: ", name)
				fields.push_back(Field.native(name, native_type_))
			i += 1

	for field in fields:
		var name := field.name
		var type := field.type
		var default_value: Variant = obj.get(name)

		if field.type.is_implicitly_defined():
			type.native_type = typeof(default_value) as Variant.Type

		assert(
			not type.is_implicitly_defined(),
			str(
				"Could not determine type of implicitly typed field '",
				field.pretty_str(obj),
				"'",
			),
		)

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
				"', is null (even optionals must have a default object)",
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


static func _get_type_name(obj: Object) -> StringName:
	var name: Variant = obj.get(_TYPE_NAME_VARNAME)
	if not name:
		name = obj.get_script().resource_path
	if not name:
		# e.g. internally defined `class`es
		name = &""
	return name


static func get_fields(obj: Object) -> Array[Field]:
	assert(obj)
	var fields: Array[Field] = []

	if obj.get_script():
		match _get_type_name(obj):
			&"":
				push_warning("Unoptimized class: ", obj, " : ", obj.get_script().resource_path)
				fields = _create_obj_fields(obj)
			var x:
				var type_name: StringName = x
				if _field_list_cache.has(type_name):
					var arr: Array = _field_list_cache[type_name]
					fields.assign(arr)
				else:
					print("Caching type '", type_name, "' based on obj: ", obj)
					fields = _create_obj_fields(obj)
					_field_list_cache[type_name] = fields

	else:
		var obj_class := StringName(obj.get_class())
		while obj_class and not _field_list_cache.has(obj_class):
			obj_class = ClassDB.get_parent_class(obj_class)
		if _field_list_cache.has(obj_class):
			var arr: Array = _field_list_cache[obj_class]
			fields.assign(arr)
		else:
			assert(
				false,
				str(
					"Unhandled class, add to gdserde._field_list_cache: '",
					obj_class,
					"'",
				),
			)
			fields = _create_obj_fields(obj)

	return fields
