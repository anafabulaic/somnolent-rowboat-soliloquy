# meta-name: Player Action
# meta-description: Base template for the PlayerAction class for use with PlayerActionManager components.
# meta-default: true
# meta-space-indent: 4

extends PlayerAction

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	pass
	
func update_physics(delta: float) -> void:
	pass
	
func can_use() -> bool:
	return true
	
func execute() -> void:
	pass
