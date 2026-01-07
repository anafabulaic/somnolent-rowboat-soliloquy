extends Node
class_name InteractableEffect

signal effect_triggered

@export var pre_delay: float = 0.0
@export var enabled: bool = true

## If enabled, effect will not be activated normally and can only be activated by other effects.
@export var reference: bool = false

## don't edit this part
func trigger() -> void:
	if !enabled:
		return
	
	if pre_delay > 0.0:
		await Main.wait(pre_delay)
	
	effect_triggered.emit()
	_effect()

## the effect we want to actually do. edit this and not trigger()
func _effect() -> void:
	pass
