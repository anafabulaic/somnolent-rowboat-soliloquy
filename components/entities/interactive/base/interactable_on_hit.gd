## Attach to an InteractableConditional. Will activate if you use a trinket while looking at it.
extends Node3D
class_name PlayerInteractableOnHit

@export var parent: PlayerInteractable
@export var enabled: bool = false

@export var being_looked_at: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.get_parent() is PlayerInteractable:
		parent = self.get_parent()
		enabled = true
		
	SignalBus.on_trinket_use.connect(do_hit)

func do_hit(trinket: TrinketReference) -> void:
	if !enabled or !parent:
		return
	
	if parent.being_looked_at:
		do_interact()

func do_interact() -> void:
	PlayerInteractableConditional.handle_mode_condition_children(self, self, true)
