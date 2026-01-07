extends InteractableEffect
class_name InteractableEffectSetEnvironment

@export var environment_node: WorldEnvironment
@export var environment: Environment

func _effect() -> void:
	if Game.current_scene and environment_node:
		environment_node.environment = environment
