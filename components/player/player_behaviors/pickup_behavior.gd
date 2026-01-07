extends PlayerBehavior
class_name PlayerPickupBehavior

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

@export_group("Base Dependencies")
@export var camera_marker: Node3D
@export var pickup_raycast: RayCast3D
@export var pickup_shapecast: ShapeCast3D
@export var hand: Marker3D
@export var physshadow: PlayerPhysShadow

@export_group("Audio")
@export var pickup_sound: AudioStreamPlayer2D
@export var pickup_error_sound: AudioStreamPlayer2D

@export_group("UI")
@export var crosshair: Crosshair

var ref_transform: Transform3D

func init() -> void:
	SignalBus.do_interact_error.connect(do_error)
	SignalBus.do_interact_lesser_error.connect(do_lesser_error)
	SignalBus.do_interact_bounce.connect(do_crosshair_bounce)
	
	hand.top_level = true
	
	pickup_raycast.add_exception(physshadow)
	pickup_shapecast.add_exception(physshadow)
	
func handle_input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("use")):
		do_interact()
	
func update(delta: float) -> void:
	if (pickup_raycast.is_colliding()):
		var coll_point: Vector3 = pickup_raycast.get_collision_point()
		var dist: float = camera_marker.global_position.distance_to(coll_point)
		var raycast_collider := pickup_raycast.get_collider()
		
		if (raycast_collider is RigidBody3D):
			crosshair.can_select = true
		elif (raycast_collider is PlayerInteractable):
			var interactable: PlayerInteractable = raycast_collider
			crosshair.can_select = interactable.can_interact
		else:
			crosshair.can_select = false
		
		crosshair.dist = dist
	else:
		crosshair.dist = 0.0
		crosshair.can_select = false
	
func physics_update(delta: float) -> void:
	update_ref_transform(delta)
	
	if (stats.is_holding && stats.held_object != null):
		update_held_object(delta)

func update_ref_transform(delta: float) -> void:
	ref_transform = camera_marker.global_transform
	
	var new_rot: Vector3 = camera_marker.global_rotation
	new_rot.x = clampf(new_rot.x, deg_to_rad(-45), deg_to_rad(89))
	
	ref_transform.basis = Basis.from_euler(new_rot)
	var dir: Vector3 = -ref_transform.basis.z * 2
	
	hand.global_position = ref_transform.origin + dir
	hand.global_basis = ref_transform.basis
	hand.global_rotation.x = 0

func update_held_object(delta: float) -> void:
	if (stats.is_holding && stats.held_object == null):
		detach()
		
	var held_object: RigidBody3D = stats.held_object
	
	var direction: Vector3 = held_object.global_transform.origin.direction_to(hand.global_position)
	var distance: float = held_object.global_transform.origin.distance_to(hand.global_position)
	
	var ang_diff_quaternion: Quaternion = hand.global_basis.get_rotation_quaternion() * held_object.quaternion.inverse()
	var ang_diff_euler: Vector3 = ang_diff_quaternion.normalized().get_euler()
	
	held_object.gravity_scale = 0.0
	held_object.can_sleep = false
	held_object.sleeping = false
	
	var result := KinematicCollision3D.new()
	if held_object.test_move(held_object.global_transform, direction * distance, result):
		if result.get_remainder().length() > 1.0:
			held_object.linear_velocity = Vector3.ZERO
			held_object.angular_velocity = Vector3.ZERO
			detach()
			return
			
	if distance > 2.0:
		held_object.linear_velocity = Vector3.ZERO
		held_object.angular_velocity = Vector3.ZERO
		detach()
		return
	
	held_object.linear_velocity = Vector3.ZERO
	held_object.angular_velocity = Vector3.ZERO
	
	var torque_force: float = held_object.mass * 10000
	var central_force: float = held_object.mass * 100000
	
	held_object.apply_torque(ang_diff_euler * torque_force * delta)
	held_object.apply_central_force(direction * distance * central_force * delta)

func do_interact() -> void:
	if (stats.is_holding):
		detach()
		return
	
	pickup_raycast.force_raycast_update()
	pickup_shapecast.force_shapecast_update()
	
	if (pickup_raycast.is_colliding()):
		var first_collider := pickup_raycast.get_collider()
		
		if !(first_collider is PhysicsProp3D):
			if first_collider is RigidBody3D:
				do_error()
			elif first_collider is PlayerInteractable:
				var interactable: PlayerInteractable = first_collider
				if interactable.can_interact:
					interactable._on_player_interact()
				else:
					do_lesser_error()
				return
			else:
				do_lesser_error()
			return
		
		if !is_pickup_too_large(first_collider):
			attach(first_collider)
		else:
			do_error()
			
	elif (pickup_shapecast.is_colliding()):
		var closest: float = 99999999
		var closest_object: RigidBody3D = null
		
		for i in pickup_shapecast.get_collision_count():
			var coll: Object = pickup_shapecast.get_collider(i)
			
			if (coll is not RigidBody3D):
				continue
				
			var dist: float = coll.global_position.distance_squared_to(hand.global_position)
			if (dist < closest):
				closest = dist
				closest_object = coll
		
		if (closest_object == null):
			return	
		
		var first_collider: RigidBody3D = closest_object
		
		if !(first_collider is PhysicsProp3D):
			if first_collider is RigidBody3D:
				do_error()
			else:
				do_lesser_error()
			return
		
		if !is_pickup_too_large(first_collider):
			attach(first_collider)
		else:
			do_error()
	else:
		do_lesser_error()

func is_pickup_too_large(node: RigidBody3D) -> bool:
	var bounding_box: AABB = Util.get_aabb(node)
	var bbox: Vector3 = bounding_box.size * node.scale
	var size: float = bbox.x * bbox.y * bbox.z

	return size > player.settings.max_prop_size || node.mass > player.stats.physshadow_mass * 2.0

func do_error() -> void:
	crosshair.do_error()
	pickup_error_sound.pitch_scale = randf_range(0.9, 1.1)
	pickup_error_sound.play()
	
func do_lesser_error() -> void:
	crosshair.do_lesser_error()
	pickup_error_sound.pitch_scale = randf_range(1.8, 2.2)
	pickup_error_sound.play()

func do_crosshair_bounce() -> void:
	crosshair.do_lesser_error()

func attach(node: RigidBody3D) -> void:
	crosshair.resize_in()
	
	pickup_sound.pitch_scale = 1.0
	pickup_sound.play()
	
	stats.held_object = node
	stats.is_holding = true

func detach() -> void:
	crosshair.resize_out()
	
	pickup_sound.pitch_scale = 0.7
	pickup_sound.play()
	
	stats.is_holding = false
	
	if !stats.held_object:
		return
		
	stats.held_object.gravity_scale = stats.held_object.prop_gravity
	stats.held_object.can_sleep = true
		
	stats.held_object = null
