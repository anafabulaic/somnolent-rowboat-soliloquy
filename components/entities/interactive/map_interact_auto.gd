extends Node3D
class_name MapInteractAuto

@export var enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.do_interact()

func do_interact() -> void:
	PlayerInteractableConditional.handle_mode_condition_children(self, self, true)
