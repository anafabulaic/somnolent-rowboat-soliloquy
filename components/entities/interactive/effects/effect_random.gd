## Chooses between the effects in its array randomly.
extends InteractableEffect
class_name InteractableEffectRandom

@export var effects: Array[InteractableEffect]
@export var use_children: bool = true ## If disabled, will use the effects array instead.

func _effect() -> void:			
	var effect_array: Array = []
		
	if use_children:
		for effect in self.get_children():
			if effect is InteractableEffect:
				effect_array.append(effect)
				
		if effect_array.is_empty():
			return
	else:
		if effects.is_empty():
			return
		
		effect_array = effects
		
	var rand_pick: int = randi_range(0, effect_array.size() - 1)
	
	effect_array[rand_pick].trigger()
