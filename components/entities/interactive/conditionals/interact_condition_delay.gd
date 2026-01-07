extends InteractCondition
class_name InteractConditionDelay

@export var delay: float = 0.1

var last_interact: int = -9999

func condition() -> bool:
	if last_interact == -9999: 
		last_interact = Time.get_ticks_msec()
		return true
	
	if (Time.get_ticks_msec() - last_interact) < (delay * 1000):
		return false
	else:
		last_interact = Time.get_ticks_msec()
		return true
		
