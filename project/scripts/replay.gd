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
	print("Saving replay to: ", filename)
	var f := FileAccess.open("replay.dat", FileAccess.ModeFlags.WRITE)
	if not f:
		return FileAccess.get_open_error()
	if not f.store_buffer(var_to_bytes(frames)):
		return ERR_INVALID_DATA
	return OK

func start() -> void:
	assert(frames, "No replay loaded")
	if frames:
		is_active = true

func stop() -> void:
	is_active = false

func next() -> Result:
	if current_frame >= frames.size():
		stop()
		return Result.fail()
	
	var out: Variant = frames[current_frame]
	current_frame += 1
	return Result.ok(out)

func add_frame(frame: Variant) -> void:
	assert(not is_active)
	if current_frame > frames.size():
		var err := frames.resize(current_frame)
		assert(err == OK)
	
	frames.push_back(frame)
