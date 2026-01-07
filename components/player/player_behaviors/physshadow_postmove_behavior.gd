extends PlayerBehavior
class_name PlayerPhysShadowPostMoveBehavior

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
	physshadow.gravity_scale = stats.gravity_modifier
	
	_do_alternate_prephysics(delta)
	
	#if Game.settings.use_alternate_physics:
		#_do_alternate_prephysics(delta)
	#else:
		#_do_postphysics()

func _do_postphysics() -> void:
	if (stats.touching_physics):
		physshadow.activate()
	else:
		physshadow.deactivate()
		physshadow.reset(player.global_transform)

func _do_alternate_prephysics(delta: float) -> void:
	# can't do it like in s&box, integrate_forces doesn't behave as expected. have to do it in this weird fucked up order
	# basically, for the physshadow:
	# start tick > integrate forces > postphysics > player logic > prephysics (YOU ARE HERE) > end tick
	# this is fucking stupid but idk a better way to do it. oh well!
	
	stats.was_touching_physics = physshadow.touching_physics

	if (stats.touching_physics):
		player.global_transform = physshadow.global_transform
	else:
		#physshadow.linear_velocity = Vector3.ZERO
		physshadow.reset(player.global_transform)
	
	if (stats.physics_active && stats.touching_physics):
		physshadow.linear_velocity += stats.velocity

		#player.global_transform = physshadow.global_transform
	#else:
		#physshadow.linear_velocity = Vector3.ZERO
		#physshadow.reset(player.global_transform)
