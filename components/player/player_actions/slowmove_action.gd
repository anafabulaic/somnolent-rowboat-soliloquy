extends PlayerAction
class_name PlayerSlowMoveAction

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	pass
		
	
func update_physics(delta: float) -> void:
	if stats.wants_slowmove:
		execute()
	
func can_use() -> bool:
	return true
	
func execute() -> void:
	stats.wish_speed = stats.wish_speed * 0.3
