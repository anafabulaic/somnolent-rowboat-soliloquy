extends PlayerBehavior
class_name PlayerPhysShadowBehavior

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

@export var physshadow: PlayerPhysShadow

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass
	#if Game.settings.use_alternate_physics:
		#return
	#
	#stats.touching_physics = physshadow.touching_physics
	#
	#if (stats.touching_physics):
		#physshadow.activate()
	#else:
		#physshadow.deactivate()
	
	#if (stats.touching_physics):
		#print("PhysShadow A: ", "%1.3v" % physshadow.linear_velocity, " | ", "%1.3v" % stats.velocity, " at ", Engine.get_physics_frames())
		#
		#stats.velocity = physshadow.linear_velocity
		#physshadow.linear_velocity -= stats.velocity
		#player.global_transform = physshadow.global_transform
		#
		#print("PhysShadow B: ", "%1.3v" % physshadow.linear_velocity, " | ", "%1.3v" % stats.velocity, " at ", Engine.get_physics_frames())
		#physshadow.activate()
	#else:
		#physshadow.deactivate()
		#physshadow.reset(player.global_transform)
