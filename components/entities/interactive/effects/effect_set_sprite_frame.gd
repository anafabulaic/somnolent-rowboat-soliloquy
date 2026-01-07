extends InteractableEffect
class_name InteractableEffectSetSpriteFrame

@export var sprite: AnimatedSprite3D
@export var frame: int = 0

## return to the previous frame after a set time
@export var return_to_prev: bool = false
@export var return_time: float = 0.0

var prev_frame: int = 0

func _effect() -> void:	
	prev_frame = sprite.frame
	
	sprite.frame = frame

	if return_to_prev:
		await Main.wait(return_time)
		if sprite:
			sprite.frame = prev_frame
