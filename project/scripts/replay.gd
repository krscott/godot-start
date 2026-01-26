class_name Replay
extends RefCounted

var is_active := false
var frames := []
var current_frame := 0

func load_from_file(filename: String) -> Error:
	var err := OK
	print("Loading replay from: ", filename)
	var replay_data := FileAccess.get_file_as_bytes(filename)
	if not replay_data:
		err = FileAccess.get_open_error()
		if err == OK:
			printerr("Empty replay")
			err = ERR_INVALID_DATA
	
	if not err:
		var maybe_frames: Variant = bytes_to_var(replay_data)
		if maybe_frames is not Array:
			printerr("Invalid frame data: ", str(maybe_frames))
			err = ERR_INVALID_DATA
		else:
			frames = maybe_frames
	
	if err:
		printerr("Error loading replay file '", filename, "': ", error_string(err))
		
	return err

func save_to_file(filename: String) -> Error:
	var err := OK
	
	if not frames:
		err = ERR_INVALID_DATA
		printerr("No frame data to save")
	
	if not err:
		print("Saving replay to: ", filename)
		var f := FileAccess.open("replay.dat", FileAccess.ModeFlags.WRITE)
		if not f:
			err = FileAccess.get_open_error()
			printerr(error_string(err))
		elif not f.store_buffer(var_to_bytes(frames)):
			printerr("Failed to store buffer")
			err = FAILED
	
	return err

func start() -> void:
	assert(frames, "No replay loaded")
	if frames:
		is_active = true

func stop() -> void:
	is_active = false

func next() -> Dictionary:
	assert(is_active)
	if current_frame >= frames.size():
		assert(false)
		return {}
	
	var out: Dictionary = frames[current_frame]
	current_frame += 1
	if current_frame >= frames.size():
		stop()
	return out

func add_frame(frame: Dictionary) -> void:
	assert(not is_active)
	if current_frame > frames.size():
		var err := frames.resize(current_frame)
		assert(err == OK)
	
	frames.push_back(frame)
