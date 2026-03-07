class_name CaptiveSequenceNode
extends RefCounted

var ID: String
var links: Array[Link] = []
var value: Variant = null

func get_id() -> String:
	return ID

func set_id(id: String) -> void:
	ID = id

func get_links():
	return links

func set_links(links: Array) -> void:
	links = links

func add_link(link: Link) -> void:
	links.append(link)

func remove_link(link: Link) -> void:
	links.erase(link)

func remove_all_links() -> void:
	links.clear()

func get_value() -> Variant:
	return value

func set_value(value: Variant) -> void:
	value = value
