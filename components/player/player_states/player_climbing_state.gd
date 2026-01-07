extends PlayerState
class_name PlayerClimbingState

# @onready var player: Player = self.owner
@export var footsteps: PlayerFootstepBehavior

func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass
	
func enter(previous_state_name: String, data: Dictionary = {}) -> void:
	if previous_state_name == "PlayerFallingState":
		footsteps.play_rand_ladder()
	
func exit() -> void:
	pass

func is_grounded() -> bool:
	return false
