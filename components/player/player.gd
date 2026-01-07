extends CharacterBody3D
class_name Player

@export var settings: GameSettings
@export var stats: PlayerStatSheet
var _base_stats: PlayerStatSheet

@export_category("Managers")
@export var _state_machine: PlayerStateMachine
@export var _behavior_manager: PlayerBehaviorManager
@export var _action_manager: PlayerActionManager
@export var _trinket_manager: PlayerTrinketManager
@export var _physshadow: PlayerPhysShadow

@export_category("Dependencies")
@export var _collider: CollisionShape3D
@export var _collider_shape: BoxShape3D
@export var _camera_head: Node3D
@export var _camera_anchor: Node3D
@export var _camera_marker: Node3D
@export var _camera: Camera3D

var locked: bool = false

func _ready() -> void:
	_init_collider()	
	_init_camera()
	_init_physshadow()
	
	SignalBus.set_fov.connect(set_fov)
	
	floor_max_angle = deg_to_rad(stats.max_walk_slope)
	
	_base_stats = stats.duplicate()

	_trinket_manager.init()
	_action_manager.init()
	_behavior_manager.init()
	
func _unhandled_input(event: InputEvent) -> void:
	if locked:
		return
	
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		stats.wants_jump = false
		stats.wants_crouch = false
		stats.wants_slowmove = false
		
		stats.wish_dir = Vector3.ZERO
		
		if Input.is_action_just_pressed("primaryfire"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	
	_build_input(event)
	_build_mouse_input(event)
	
	_trinket_manager.handle_trinkets_input(event)
	_action_manager.handle_actions_input(event)
	_behavior_manager.handle_behavior_input(event)

func _process(delta: float) -> void:
	_trinket_manager.process_trinkets(delta)
	_behavior_manager.process_behaviors(delta)
	_state_machine.process_states(delta)
		
func _physics_process(delta: float) -> void:
	if Game.current_save:
		Game.current_save.seconds_played += delta
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and !locked:
		stats.wish_dir = get_wish_dir()
	else:
		stats.wish_dir = Vector3.ZERO
	
	if locked:
		return
	
	stats.wish_speed = stats.base_speed
	
	# can't do it like in s&box, integrate_forces doesn't behave as expected. have to do it in this weird fucked up order
	# basically, for the physshadow:
	# start tick > integrate forces > postphysics (YOU ARE HERE) > player logic > prephysics > end tick
	# this is fucking stupid but idk a better way to do it. oh well!
	_do_postphysics()

	_trinket_manager.process_trinkets_physics(delta)
	_action_manager.process_actions_physics(delta)
	_behavior_manager.process_behaviors_physics(delta)
	_state_machine.process_states_physics(delta)
	
	if Game.current_scene and global_position.y < Game.current_scene.void_level:
		Game.awaken()

func _build_input(event: InputEvent) -> void:
	stats.wants_jump = Input.is_action_just_pressed("jump")
	stats.wants_crouch = Input.is_action_pressed("crouch")
	stats.wants_slowmove = Input.is_action_pressed("slowmove")
	
func _build_mouse_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED && event is InputEventMouseMotion:
		stats.mouse_input += event.screen_relative
		#var viewport_transform: Transform2D = get_tree().root.get_final_transform()
		#stats.mouse_input += event.xformed_by(viewport_transform).relative

func lock(pause: bool = false) -> void:
	if pause: Game.can_pause = false
	
	stats.can_land = false
	stats.can_move_and_slide = false
	_collider.disabled = true
	_physshadow.collider.disabled = true
	locked = true
	
func unlock(pause: bool = false) -> void:
	if pause: Game.can_pause = true
	
	stats.can_move_and_slide = true
	_collider.disabled = false
	_physshadow.collider.disabled = false
	locked = false

func enable_steps() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	stats.can_land = true

func _do_postphysics() -> void:
	stats.touching_physics = _physshadow.touching_physics
	
	if (stats.physics_active && stats.was_touching_physics):
		stats.velocity = _physshadow.linear_velocity
		_physshadow.linear_velocity -= stats.velocity
	
	#stats.physground_velocity = _physshadow.ground_velocity
	
	if (stats.touching_physics):
		_physshadow.activate()
	else:
		_physshadow.deactivate()
	
	stats.physics_active = _physshadow.active
	
	if (stats.physics_active):
		global_transform = _physshadow.global_transform
	else:
		_physshadow.linear_velocity = Vector3.ZERO
		_physshadow.reset(global_transform)
		

#region Helper Functions
func is_grounded() -> bool:
	return get_current_state().is_grounded()

func set_hull_height(height: float) -> void:	
	_physshadow.set_hull_height(height)
	
	_collider_shape.size.y = height
	_collider.position = Vector3(0, height / 2, 0)

func apply_gravity(vel: Vector3, gravity: Vector3, delta: float) -> Vector3:
	vel += gravity * 0.5 * delta
	return vel
	
func set_player_transform(trans: Transform3D) -> void:
	global_position = trans.origin
	_physshadow.global_position = trans.origin
	_camera_anchor.global_position = _camera_marker.global_position
	_camera_head.global_rotation.y = trans.basis.get_euler().y
	_camera_marker.rotation = Vector3.ZERO
	_camera_anchor.global_rotation = _camera_marker.global_rotation
	
func set_fov(fov: float) -> void:
	_camera.fov = fov
	
func get_input_dir() -> Vector2:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	return input_dir
	
func get_wish_dir() -> Vector3:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (_camera_head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	return direction

func get_camera_dir() -> Vector3:
	var direction: Vector3 = (-_camera_marker.global_basis.z * Vector3(1, 1, 1)).normalized()
	
	return direction
	
func get_camera_wish_dir() -> Vector3:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (_camera_marker.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	return direction
#endregion
	
#region Syntactic Sugar
func get_current_state() -> PlayerState:
	return _state_machine.current_state

# TODO: replace param with an enum or something later so it's less fragile
func set_state(state: String) -> void:
	_state_machine.set_state(state)
	
func has_trinket(item: TrinketReference) -> bool:
	return _trinket_manager.has_trinket(item)
	
func add_trinket(item: TrinketReference) -> void:
	_trinket_manager.add_trinket(item)
#endregion
	
#region Init
func _init_collider() -> void:
	var radius: float = stats.character_radius
	var height: float = stats.character_height
	
	_collider_shape.size = Vector3(radius, height, radius)
	_collider.shape = _collider_shape
	
	_collider.position = Vector3(0.0, height * 0.5, 0.0)
	
func _init_camera() -> void:
	var height: float = stats.camera_height
	var fov: float = settings.fov
	
	_camera_head.position = Vector3(0.0, height, 0.0)
	
	_camera_anchor.top_level = true
	_camera_anchor.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_camera.fov = fov
	
func _init_physshadow() -> void:
	_physshadow.initialize()
	
	add_collision_exception_with(_physshadow)
#endregion
