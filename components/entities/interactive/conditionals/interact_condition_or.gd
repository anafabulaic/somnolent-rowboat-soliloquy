## Takes other conditions as inputs and acts as an OR gate for them.
extends InteractCondition
class_name InteractConditionOr

@export var input_conditions: Array[InteractCondition]

func condition() -> bool:
	if input_conditions.is_empty():
		return false
	
	var con_bool: bool = false
	
	for con: InteractCondition in input_conditions:
		if !con.reference:
			push_warning("you forgot to set ", con.name, " to reference, dingus!")
		
		if con.get_condition():
			return true
	
	return con_bool
