extends InteractableEffect
class_name InteractableEffectMultiple

@export var effects: Array[InteractableEffect]
@export var use_children: bool = false

func _effect() -> void:	
	if use_children:
		for effect in self.get_children():
			if effect is InteractableEffect:
				effect.trigger()
		return
		
	for effect in effects:
		effect.trigger()
