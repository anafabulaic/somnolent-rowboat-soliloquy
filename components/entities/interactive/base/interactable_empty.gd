## Does nothing by itself, activate with signals or whatever.
extends Node3D
class_name PlayerInteractableEmpty

func do_interact() -> void:
	PlayerInteractableConditional.handle_mode_condition_children(self, self, true)
