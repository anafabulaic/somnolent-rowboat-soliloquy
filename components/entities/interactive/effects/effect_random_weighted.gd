## Chooses between the effects in its array randomly, with weights assigned to each one.
extends InteractableEffect
class_name InteractableEffectRandomWeighted

@export var effects: Dictionary[InteractableEffect, float]

func _effect() -> void:	
	if effects.is_empty():
		return
	
	var rng := RandomNumberGenerator.new()
	
	var weighted_index: int = rng.rand_weighted(effects.values())
	
	effects.keys()[weighted_index].trigger()
