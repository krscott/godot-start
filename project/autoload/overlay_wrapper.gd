extends Node

# Godot bug: Autoloaded scenes do not have type information.
# This class is a workaround until fix is merged:
# https://github.com/godotengine/godot/pull/98313

var n: AutoloadOverlay = overlay_
