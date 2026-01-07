extends RigidBody3D
class_name PlayerPhysShadow

@export var player: Player
@export var stats: PlayerStatSheet
@export var collider_shape: BoxShape3D
@export var collider: CollisionShape3D

var active: bool = false
var grounded: bool = false
var physgrounded: bool = false
var touching_physics: bool = false

var prev_velocity: Vector3 = Vector3.ZERO
var ground_velocity: Vector3 = Vector3.ZERO

var contacts: int = 0

func initialize() -> void:
	collider.position = Vector3(0, collider_shape.size.y / 2, 0)
	
	top_level = true
	contact_monitor = true
	continuous_cd = true
	max_contacts_reported = 32
	
	lock_rotation = true
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	
	add_collision_exception_with(player)
	
	mass = player.stats.physshadow_mass

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	touching_physics = false
	physgrounded = false
	grounded = false
	ground_velocity = Vector3.ZERO
	
	for i in state.get_contact_count():
		if state.get_contact_collider_object(i) is RigidBody3D:
			touching_physics = true
		if (Vector3.UP.angle_to(state.get_contact_local_normal(i)) < deg_to_rad(stats.max_walk_slope)):
			if state.get_contact_collider_object(i) is RigidBody3D:
				physgrounded = true
				
				#ground_velocity = state.get_contact_collider_velocity_at_position(i)
			grounded = true
		
	contacts = state.get_contact_count()
	#print(state.get_contact_count())	

	#if !active || Game.settings.use_alternate_physics:
		#return
		#
	#state.linear_velocity = stats.velocity
#
	#player.global_transform = global_transform

func activate() -> void:
	active = true
	
func deactivate() -> void:
	active = false

func reset(trans: Transform3D) -> void:
	global_transform = trans
	
func is_colliding_with_physics() -> bool:
	var colliding_bodies := get_colliding_bodies()

	if (colliding_bodies.is_empty()):
		return false
	
	for body in colliding_bodies:
		if body is RigidBody3D: return true
		
	return false

func set_hull_height(height: float) -> void:
	collider_shape.size.y = height
	collider.position = Vector3(0, height / 2, 0)
