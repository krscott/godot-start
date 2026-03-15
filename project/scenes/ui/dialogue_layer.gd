extends CanvasLayer

@onready var _dialogue_label: RichTextLabel = %DialogueLabel
@onready var _choices_container: Container = %Choices
@onready var _button_template: Button = %ButtonTemplate
@onready var _advance_hint_label: Label = %AdvanceHint


func _ready() -> void:
	assert(_dialogue_label)
	assert(_choices_container)
	assert(_button_template)
	assert(_advance_hint_label)


func _process(_delta: float) -> void:
	pass
