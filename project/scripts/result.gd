class_name Result
extends RefCounted

var value: Variant = null
var err: Error = OK

func _init(value_: Variant, err_: Error) -> void:
	value = value_
	err = err_

static func ok(value_: Variant) -> Result:
	return Result.new(value_, OK)

static func fail(err_: Error = FAILED) -> Result:
	assert(err_ != OK)
	return Result.new(null, err_)
