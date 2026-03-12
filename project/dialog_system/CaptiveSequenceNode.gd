class_name CaptiveSequenceNode
extends RefCounted

var id: String
var links: Array[Link] = []
var value: Variant = null

func get_available_links() -> Array[Link]:
	return links.filter(func(link: Link): return link.is_available())

func set_links(_links: Array) -> void:
	links = _links

func add_link(link: Link) -> void:
	links.append(link)

func remove_link(link: Link) -> void:
	links.erase(link)

func remove_all_links() -> void:
	links.clear()

func get_value() -> Variant:
	return value

func set_value(_value: Variant) -> void:
	value = _value
