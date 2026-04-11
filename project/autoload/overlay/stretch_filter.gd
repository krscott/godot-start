extends CanvasLayer

func _ready() -> void:
	visible = false
	util.a_ok(overlay.dither_filter_pub.changed.connect(set_visible))
