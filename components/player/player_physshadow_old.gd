#extends RigidBody3D
#class_name PlayerPhysShadow
#
#@export var player: CharacterPlayer
#@export var stats: PlayerStatSheet
#@export var collider_shape: BoxShape3D
#@export var collider: CollisionShape3D
#
#var velocity: Vector3 = Vector3.ZERO
#var active: bool = false
#
#var grounded: bool = false
#
#func initialize() -> void:
	#collider.position = Vector3(0, collider_shape.size.y / 2, 0)
	#top_level = true
	#contact_monitor = true
#
	#add_collision_exception_with(player)
	#
	##collision_layer = 0
	##collision_mask = 0
#
#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#if (active == false):
		#return
	#
	#grounded = false
	#
	#for i in state.get_contact_count():
		#if (Vector3.UP.angle_to(state.get_contact_local_normal(i)) < deg_to_rad(stats.max_walk_slope)):
			#grounded = true
#
	#player.velocity = player.movement.move(state.linear_velocity, state.step) 
	#
	#state.linear_velocity = player.velocity
	#
	#player.global_transform = global_transform
#
	##call_deferred("post_physics", state.step)
	#
#func activate() -> void:
	#sleeping = false
	#can_sleep = false
	#freeze = false
	#contact_monitor = true
#
	#active = true
	#
#func deactivate() -> void:
	#sleeping = true
	#can_sleep = true
	#freeze = true
	#contact_monitor = true
#
	#active = false
	#
#func reset(trans: Transform3D) -> void:
	#global_transform = trans
	#
#func is_colliding_with_physics() -> bool:
	#var colliding_bodies := get_colliding_bodies()
#
	#if (colliding_bodies.is_empty()):
		#return false
	#
	#for body in colliding_bodies:
		#if body is RigidBody3D: return true
		#
	#return false
#
#func set_hull_height(height: float) -> void:
	#collider_shape.size.y = height
	#collider.position = Vector3(0, height / 2, 0)
