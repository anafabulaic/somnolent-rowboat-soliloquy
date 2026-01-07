extends PlayerState
class_name PlayerNoclipState

@export var collider: CollisionShape3D
@export var phys_collider: CollisionShape3D
# @onready var player: Player = self.owner

func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass
	
func enter(previous_state_name: String, data: Dictionary = {}) -> void:
	collider.disabled = true
	phys_collider.disabled = true
	
func exit() -> void:
	collider.disabled = false
	phys_collider.disabled = false
