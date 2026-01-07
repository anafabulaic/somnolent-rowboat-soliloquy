extends PlayerState
class_name PlayerFallingState

# @onready var player: Player = self.owner

func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	var phys: PlayerPhysShadow = player._physshadow

	if phys.touching_physics:
		if phys.grounded:
			finished.emit("PlayerGroundedState")
	else:
		if player.is_on_floor():
			finished.emit("PlayerGroundedState")
	
func enter(previous_state_name: String, data: Dictionary = {}) -> void:
	pass
	
func exit() -> void:
	pass

func is_grounded() -> bool:
	return false
