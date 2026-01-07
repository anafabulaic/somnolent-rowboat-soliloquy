extends Trinket
class_name TestTrinketTwo

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet = player.stats

func init() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func update_physics(delta: float) -> void:
	pass

func can_use() -> bool:
	return true
	
func execute() -> void:
	pass

func do_stats_postmove(_stats: PlayerStatSheet) -> void:
	if Input.is_action_just_pressed("primaryfire"):
		print("Used test trinket 2")
		SignalBus.sound_play_3D.emit(System.sound.ui_trinket_get, player.global_position, -5.0, 1.0, "UI")
		#_stats.velocity.y += 5.0
	#if Input.is_action_pressed("primaryfire"):
		#_stats.gravity_modifier = 0.2
	#else:
		#_stats.gravity_modifier = player._base_stats.gravity_modifier
