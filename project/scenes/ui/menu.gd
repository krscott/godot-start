class_name Menu
extends CanvasLayer

enum SpecKind {
	BUTTON,
}

class Spec:
	var kind: SpecKind
	var text: String
	var callback: Callable
	var action: StringName = &""
	func _init(kind_: SpecKind) -> void:
		kind = kind_

static func btn(text: String, callback: Callable, action: StringName = &"") -> Spec:
	var spec := Spec.new(SpecKind.BUTTON)
	spec.text = text
	spec.callback = callback
	spec.action = action
	return spec

@onready var title_label: Label = %Title

@onready var _items_container: Node = %ItemsContainer
@onready var _templates := {
	SpecKind.BUTTON: %ButtonTemplate,
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
			if x.action and Input.is_action_just_pressed(x.action):
				print("Menu: ", x.action, " -> ", x.text)
				x.callback.call()
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
		var k := x.kind
		match k:
			SpecKind.BUTTON:
				var button := _dupe_template(k) as Button
				button.text = x.text
				util.expect_ok(button.pressed.connect(x.callback))
			_:
				assert(false, str("KIND NOT IMPLEMENTED: ", k))

	_spec = spec
