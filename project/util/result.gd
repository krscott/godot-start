class_name Result

var value: Variant
var err: String
var _stack: Array


static func ok(value_: Variant) -> Result:
	return Result.new(value_, "")


static func fail(...args: Array) -> Result:
	var msg: String = str.callv(args)
	return Result.new(null, msg)


func _init(value_: Variant, err_: String) -> void:
	value = value_
	err = err_
	if err:
		_stack = get_stack() # NOTE: Debug-only by default


func context(...args: Array) -> Result:
	if err:
		args.push_back(" ")
		args.push_back(err)
		err = str.callv(args)
	return self


func expect_ok() -> void:
	if err:
		push_error(err)
		if _stack:
			print("gdserde error: ", err)
			util.print_saved_stack(_stack, 1)
		assert(false, str(err, " (see console for full stack trace)"))
