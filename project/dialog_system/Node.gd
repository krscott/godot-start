var ID: int
var links: Array[Link] = []

func get_id() -> int:
	return ID

func set_id(id: int) -> void:
	ID = id

func get_links() -> Array[Link]:
	return links

func set_links(links: Array[Link]) -> void:
	links = links

func add_link(link: Link) -> void:
	links.append(link)

func remove_link(link: Link) -> void:
	links.erase(link)

func remove_all_links() -> void:
	links.clear()