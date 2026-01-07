extends Area3D
class_name MapInteractVolume

@export var trigger_on_enter: bool = false
@export var trigger_on_exit: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(on_enter)
	self.body_exited.connect(on_exit)

func on_enter(body: Node3D) -> void:
	if trigger_on_enter:
		do_interact()

func on_exit(body: Node3D) -> void:
	if trigger_on_exit:
		do_interact()

func do_interact() -> void:
	PlayerInteractableConditional.handle_mode_condition_children(self, self, true)
