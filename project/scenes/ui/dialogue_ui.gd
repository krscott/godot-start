class_name DialogueUI
extends CanvasLayer

@onready var _panel: PanelContainer = %Panel
@onready var _label: RichTextLabel = %DialogueLabel
@onready var _choices: VBoxContainer = %Choices
@onready var _advance_hint: Label = %AdvanceHint

var _visitor: SequenceVisitor
var _awaiting_advance := false


func _ready() -> void:
	set_process_unhandled_input(false)


func bind(visitor: SequenceVisitor) -> void:
	_visitor = visitor
	visitor.show_line.connect(_on_show_line)
	visitor.show_choices.connect(_on_show_choices)
	visitor.dialogue_ended.connect(_on_dialogue_ended)
	_panel.show()
	set_process_unhandled_input(true)


func _on_show_line(line: String) -> void:
	_label.text = line
	_choices.hide()
	_advance_hint.show()
	_awaiting_advance = true


func _on_show_choices(choices: Array) -> void:
	_advance_hint.hide()
	_awaiting_advance = false

	for child in _choices.get_children():
		child.queue_free()

	for i in choices.size():
		var btn := Button.new()
		btn.text = choices[i]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.flat = true
		btn.pressed.connect(_on_choice_selected.bind(i))
		_choices.add_child(btn)

	_choices.show()
	_label.text = ""
	await get_tree().process_frame
	_choices.get_child(0).grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _awaiting_advance and event.is_action_pressed("ui_accept"):
		_awaiting_advance = false
		get_viewport().set_input_as_handled()
		_visitor.advance()


func _on_choice_selected(index: int) -> void:
	_choices.hide()
	_visitor.choose(index)


func _on_dialogue_ended() -> void:
	_panel.hide()
	set_process_unhandled_input(false)
	_visitor.show_line.disconnect(_on_show_line)
	_visitor.show_choices.disconnect(_on_show_choices)
	_visitor.dialogue_ended.disconnect(_on_dialogue_ended)
	_visitor = null
