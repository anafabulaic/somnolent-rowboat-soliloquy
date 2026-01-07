class_name TimeSince

var _time: float
var value: float:
	get: 
		return (Time.get_ticks_msec() - _time) / 1000
	set(value):
		pass

func _init() -> void:
	reset()

func reset() -> void:
	_time = Time.get_ticks_msec()
	
