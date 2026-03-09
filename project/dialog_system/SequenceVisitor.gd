class_name SequenceVisitor
extends Node

## Drives traversal of a CaptiveSequenceNode graph.
##
## Flow:
##   1. visit(start_node) suspends player input and begins the dialogue.
##   2. At each node, available links (conditions pass) are gathered.
##   3. If >1 available link and all have text: emit show_choices([first_line_per_link]).
##      UI calls choose(index) to continue.
##   4. For the chosen link (or the sole available link):
##        - fire "before_dialogue" callback
##        - emit show_line for each body line (lines[1:])
##          UI calls advance() after each line
##        - fire "after_dialogue" callback
##   5. Follow link.next_node. If null, emit dialogue_ended and restore player input.
##
## Connect to:
##   show_choices(choices: Array[String])  -> display a choice menu; call choose(i) when selected
##   show_line(line: String)               -> display one line; call advance() when dismissed
##   dialogue_ended                        -> hide dialogue UI, restore player state
##
## Call externally:
##   choose(index: int)  -- after show_choices
##   advance()           -- after show_line

## Emitted when a choice menu should be shown. choices = first line of each available link.
signal show_choices(choices: Array)
## Emitted for each body line of the selected link (lines after the choice line).
signal show_line(line: String)
## Emitted when the dialogue graph is exhausted (next_node == null).
signal dialogue_ended

## Internal flow-control signals.
signal _choice_confirmed(index: int)
signal _advance_requested

var _player_input: PlayerInput


## Begin traversal. Suspends player input until dialogue_ended.
func visit(start_node: CaptiveSequenceNode, player_input: PlayerInput) -> void:
	_player_input = player_input
	_player_input.listening = false

	var current: CaptiveSequenceNode = start_node

	while current != null:
		var available: Array[Link] = _get_available_links(current)

		if available.is_empty():
			break

		var chosen_link: Link

		if available.size() == 1:
			chosen_link = available[0]
		else:
			# All links have text: show choice line (lines[0]) of each as a menu.
			var choices: Array[String] = []
			for link in available:
				choices.append(link.get_choice_line())
			show_choices.emit(choices)
			var idx: int = await _choice_confirmed
			chosen_link = available[idx]

		current = await _traverse_link(chosen_link)

	dialogue_ended.emit()
	_player_input.listening = true


## Called by UI when the player selects a choice at index `index`.
func choose(index: int) -> void:
	_choice_confirmed.emit(index)


## Called by UI when the player dismisses the current line.
func advance() -> void:
	_advance_requested.emit()


## Returns the next node after fully traversing a link.
func _traverse_link(link: Link) -> CaptiveSequenceNode:
	_fire_callback(link, &"before_dialogue")

	# lines[0] is the choice/title line; lines[1:] are the body.
	var body := link.get_lines().slice(1)
	for line in body:
		show_line.emit(line)
		await _advance_requested

	_fire_callback(link, &"after_dialogue")

	return link.get_next_node()


## Returns links whose conditions all pass (or that have no conditions).
func _get_available_links(node: CaptiveSequenceNode) -> Array[Link]:
	var out: Array[Link] = []
	for link in node.get_links():
		if link.is_available():
			out.append(link)
	return out


## Calls the callable stored under `key` in the link's callbacks dict, if present.
func _fire_callback(link: Link, key: StringName) -> void:
	var cb: Variant = link.get_callbacks().get(key, null)
	if cb is Callable:
		cb.call()
