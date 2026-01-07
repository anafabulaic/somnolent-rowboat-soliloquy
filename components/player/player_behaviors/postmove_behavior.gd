extends PlayerBehavior
class_name PostmoveBehavior

@export var physshadow: PlayerPhysShadow

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	if !player.is_grounded():
		stats.velocity = player.apply_gravity(stats.velocity, stats.gravity * stats.gravity_modifier, delta)
	
	SignalBus.on_postmove.emit(stats, delta)
