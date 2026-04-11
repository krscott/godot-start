extends Node

var game_started_pub := pubsub.Bool.new()

var paused_pub := pubsub.Bool.new()
var menu_open_pub := pubsub.Bool.new()

var stretch_fitler_pub := pubsub.Bool.new()
var palette_filter_pub := pubsub.Bool.new()
var dither_filter_pub := pubsub.Bool.new()
