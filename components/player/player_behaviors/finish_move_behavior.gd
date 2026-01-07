extends PlayerBehavior
class_name FinishMoveBehavior

# @onready var player: Player = self.owner

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	SignalBus.on_premove.emit(stats, delta)
	
	if stats.touching_physics:
		return
	
	player.velocity = stats.velocity
	
	if stats.can_move_and_slide:
		player.move_and_slide()
		
	stats.velocity = player.velocity
