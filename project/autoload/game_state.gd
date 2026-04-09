extends Node

var game_started := pubsub.Bool.new()
var game_paused := pubsub.Bool.new()

var palette_filter := pubsub.Bool.new()
var dither_filter := pubsub.Bool.new()

var show_menu_on_startup := true
var pause_on_statup := true
