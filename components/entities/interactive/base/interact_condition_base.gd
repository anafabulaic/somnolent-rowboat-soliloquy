extends Node
class_name InteractCondition

signal condition_false
signal condition_true

## Invert the condition i.e if it would be true normally, return false instead
@export var invert: bool = false

## Don't consider this condition at all. Useful in conjunction with conditions that specifically rely on other conditions.
@export var reference: bool = false

## Override this condition's return value to that of the override property.
@export var use_override: bool = false
@export var override: bool = true

## use this to get the condition. override condition() instead in derived classes
func get_condition() -> bool:
	var con := condition() != invert
	
	if con: condition_true.emit()
	else: condition_false.emit()
	
	if use_override:
		return override
	
	return con

## our actual condition. edit this for custom conditions
func condition() -> bool:
	return true
