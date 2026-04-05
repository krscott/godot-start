extends Button

var _counter := 0


func _ready() -> void:
	reinput.intercept_signal(self, &"pressed", _on_click)


func _on_click() -> void:
	_counter += 1
	text = str("Pressed: ", _counter)
