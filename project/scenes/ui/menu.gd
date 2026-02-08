class_name Menu
extends CanvasLayer

enum SpecKind {
	BUTTON,
	CHECKBOX,
}

class Spec:
	var _kind: SpecKind
	var _text: String
	var _callback: Callable
	var _action: StringName = &""
	var _button_pressed: bool = false

	func action(action_: StringName) -> Spec:
		_action = action_
		return self

	func toggled(value: bool = true) -> Spec:
		_button_pressed = value
		return self

static func button(text: String, callback: Callable) -> Spec:
	var spec := Spec.new()
	spec._kind = SpecKind.BUTTON
	spec._text = text
	spec._callback = callback
	return spec

static func checkbox(text: String, callback: Callable) -> Spec:
	var spec := Spec.new()
	spec._kind = SpecKind.CHECKBOX
	spec._text = text
	spec._callback = callback
	return spec

@onready var title_label: Label = %Title

@onready var _items_container: Node = %ItemsContainer
@onready var _templates := {
	SpecKind.BUTTON: %ButtonTemplate,
	SpecKind.CHECKBOX: %CheckBoxTemplate,
}

var _spec: Array[Spec] = []
var _was_visible_last_frame := false

func _ready() -> void:
	assert(title_label)
	assert(_items_container)
	title_label.text = ProjectSettings.get_setting("application/config/name")
	hide()
	for k: SpecKind in _templates:
		_get_template(k).hide()


func _process(_delta: float) -> void:
	if _was_visible_last_frame and visible:
		for x in _spec:
			if x._action and Input.is_action_just_pressed(x._action):
				print("Menu: ", x._action, " -> ", x._text)
				x._callback.call()
	_was_visible_last_frame = visible


func _get_template(kind: SpecKind) -> Control:
	assert(_templates.has(kind), str("Missing template for kind: ", kind))
	return _templates[kind]


func _dupe_template(kind: SpecKind) -> Node:
	var new_node: Control = _get_template(kind).duplicate()
	_items_container.add_child(new_node)
	new_node.show()
	return new_node


func build(spec: Array[Spec]) -> void:
	assert(_spec.size() == 0, "TODO: clear old spec")

	for x in spec:
		var k := x._kind
		match k:
			SpecKind.BUTTON:
				var button_ := _dupe_template(k) as Button
				button_.text = x._text
				util.aok(button_.pressed.connect(x._callback))
			SpecKind.CHECKBOX:
				var checkbox_ := _dupe_template(k) as CheckBox
				checkbox_.text = x._text
				checkbox_.button_pressed = x._button_pressed
				print("Initial button_pressed: ", checkbox_.button_pressed)
				util.aok(checkbox_.toggled.connect(x._callback))
			_:
				assert(false, str("KIND NOT IMPLEMENTED: ", k))

	_spec = spec
