## Continuous SerDe Helper
class_name DataTape

var _buffer := PackedByteArray()
var _offset := 0


func _init(buffer: PackedByteArray = PackedByteArray()) -> void:
	_buffer = buffer


func done() -> bool:
	return _offset >= _buffer.size()


func append(variant: Variant) -> void:
	# TODO: Investigate compression
	_buffer.append_array(var_to_bytes(variant))
	_offset = _buffer.size()


func take() -> Variant:
	assert(_offset < _buffer.size())
	var var_size := _buffer.decode_var_size(_offset)
	var variant: Variant = _buffer.decode_var(_offset)
	_offset += var_size
	return variant


func clear() -> void:
	_buffer.clear()
	_offset = 0


func rewind() -> void:
	_offset = 0


func size() -> int:
	return _buffer.size()
