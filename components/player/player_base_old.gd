#extends CharacterBody3D
#class_name CharacterPlayer
#
#@export var collider_shape: BoxShape3D
#@export var collider: CollisionShape3D
#
#@export_group("Dependencies")
#@export var movement: PlayerMovement
#@export var stat_manager: PlayerStats
#@export var camera: PlayerCamera
#@export var physshadow: PlayerPhysShadow
#
#@export_group("Stats")
#@export var settings: GameSettings
#@export var statsheet: PlayerStatSheet
#
#var old_layer: int
#var old_mask: int
#
#var is_colliding: bool = false
#var can_move_and_slide: bool = true
#
#var mouse_input: Vector2
#
#func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#
	#initialize_collider()
	#
	#camera.initialize(settings)
	#camera.position = Vector3(0, stat_manager.camera_height, 0)
	#
	#physshadow.initialize()
	##add_collision_exception_with(physshadow)
	#
	#movement.initialize()
#
#func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("ui_cancel"):
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#
	#if Input.is_action_just_pressed("primaryfire") and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#
	#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED && event is InputEventMouseMotion:
		#var viewport_transform: Transform2D = get_tree().root.get_final_transform()
		#mouse_input += event.xformed_by(viewport_transform).relative
	#
#func _notification(what: int) -> void:
	#if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#
#func _process(delta: float) -> void:
	#if (get_input_dir().length() > 0 && grounded()):
		#camera.headbob_effect(velocity, delta)
	#
	#camera.handle_input(mouse_input)
	#mouse_input = Vector2.ZERO
	#
	##movement.stairstep.update(delta)
#
#func _physics_process(delta: float) -> void:
	#var is_colliding_shadow := physshadow.is_colliding_with_physics()
	#is_colliding = is_colliding_shadow
	##print("physshadow active: ", physshadow.active, " | is colliding: ", is_colliding, " | grounded: ", grounded(), "/", physshadow.grounded)
	#
	#if (is_colliding):
		#physshadow.activate()
	#else:	
		#physshadow.deactivate()
#
		#velocity = movement.move(velocity, delta)
		##movement.stairstep.physics_update(delta)
		#
		#if can_move_and_slide:
			#move_and_slide()
			#
		#if (!grounded()):
			#velocity = movement.apply_gravity(velocity, delta)
		#physshadow.velocity = velocity
		#
		#physshadow.reset(global_transform)
	#
	#camera.sync_transform(global_transform)
	#
	#movement.update_grounded(grounded())
#
##func is_colliding_with_physics() -> bool:
	##if (physshadow.active):
		##return false
	##
	##for i in range(get_slide_collision_count()):
		##var collision := get_slide_collision(i)
		##var colliding := collision.get_collider()
		##
		##if (colliding.get_instance_id() == physshadow.collider.get_instance_id()):
			##continue
		##
		##if (colliding is RigidBody3D): return true
##
	##return false
#
#func initialize_collider() -> void:
	#collider_shape.size = Vector3(stat_manager.character_radius, stat_manager.character_height, stat_manager.character_radius)
	#collider.shape = collider_shape
	#
	#collider.position = Vector3(0, stat_manager.character_height / 2, 0)
	#
#func grounded() -> bool:
	#if (physshadow.active):
		#return physshadow.grounded
	#else:
		#return is_on_floor()
	#
#func get_input_dir() -> Vector2:
	#var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
#
	#return input_dir
#
#func get_wish_dir() -> Vector3:
	#var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	#var direction: Vector3 = (camera.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#
	#return direction
#
#func get_camera_dir() -> Vector3:
	#var direction: Vector3 = (-camera.get_camera_basis().z * Vector3(1, 1, 1)).normalized()
	#
	#return direction
#
#func set_hull_height(height: float) -> void:
	#collider_shape.size.y = height
	#collider.position = Vector3(0, height / 2, 0)
	#physshadow.set_hull_height(height)
