extends Button

var _counter := 0


func _ready() -> void:
	reinput.connect_signal(self, &"pressed")
	util.a_ok(pressed.connect(_on_click))


func _on_click() -> void:
	_counter += 1
	text = str("Pressed: ", _counter)
