extends PlayerBehavior
class_name PlayerInteractBehavior

@export_group("Base Dependencies")
@export var camera_marker: Node3D
@export var pickup_raycast: RayCast3D

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	if pickup_raycast.is_colliding():
		var first_collider := pickup_raycast.get_collider()
		
		if first_collider is PlayerInteractable:
			var interactable: PlayerInteractable = first_collider
			interactable._on_player_look_at()
