# meta-name: Player State
# meta-description: Base template for the PlayerState class for use with PlayerStateMachine components.
# meta-default: true
# meta-space-indent: 4

extends PlayerState

# @onready var player: Player = self.owner

func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass
	
func enter(previous_state_name: String, data: Dictionary = {}) -> void:
	pass
	
func exit() -> void:
	pass
