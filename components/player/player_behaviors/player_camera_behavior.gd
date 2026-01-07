extends PlayerBehavior
class_name PlayerCameraBehavior

@export var camerahead: Node3D
@export var cameramarker: Node3D
@export var camera_anchor: Node3D
@export var camera_smooth: Node3D

var dotsPer360: float = 16363.6364
var radiansPerDot: float = TAU / dotsPer360
var sens: float

var headbob_frequency: float
var headbob_move_amount: float

var head_tilt_rot: float = 0.0

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	sync_camera_rot_to_marker()
	
func physics_update(delta: float) -> void:
	rotate_camera(delta)
	
	var mouse_input: Vector2 = stats.mouse_input
	
	move_camera(mouse_input)
	clear_mouse_input()
	
	camerahead.position.y = stats.desired_camera_height
	
	if (stats.wish_dir.length_squared() > 0 && player.is_grounded()):
		if Game.settings.use_headbobbing:
			headbob_effect(stats.velocity, delta)
		else:
			cameramarker.transform.origin = Vector3.ZERO
		
	sync_camera_pos_to_marker()

func rotate_camera(delta: float) -> void:
	var precon: bool = player.is_grounded() && stats.velocity.length_squared() > 0
	var head_tilt_angle: float = 2.0
	var head_tilt_speed: float = delta * 10.0
	var rest_speed: float = delta * 10.0
	
	if Input.is_action_pressed("move_left") && precon:
		head_tilt_rot = move_toward(head_tilt_rot, head_tilt_angle, head_tilt_speed)
	elif Input.is_action_pressed("move_right") && precon:
		head_tilt_rot = move_toward(head_tilt_rot, -head_tilt_angle, head_tilt_speed)
	else:
		head_tilt_rot = move_toward(head_tilt_rot, 0, rest_speed)
		
	camera_smooth.rotation.z = deg_to_rad(head_tilt_rot)

func move_camera(mouse_input: Vector2) -> void:
	sens = player.settings.mouse_sensitivity * radiansPerDot
	
	camerahead.rotate_y(-mouse_input.x * sens)
	cameramarker.rotate_x(-mouse_input.y * sens)
	cameramarker.rotation.x = clampf(cameramarker.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
func clear_mouse_input() -> void:
	stats.mouse_input = Vector2.ZERO

func sync_camera_pos_to_marker() -> void:
	camera_anchor.global_position = cameramarker.get_global_transform_interpolated().origin

func sync_camera_rot_to_marker() -> void:
	camera_anchor.global_rotation = cameramarker.get_global_transform_interpolated().basis.get_euler()

func sync_camera_to_marker() -> void:
	camera_anchor.global_transform = cameramarker.get_global_transform_interpolated()

func headbob_effect(velocity: Vector3, delta: float) -> void:	
	headbob_frequency = Game.settings.headbob_frequency
	headbob_move_amount = Game.settings.headbob_amount
	
	stats.step_time += stats.velocity.length() * delta
	cameramarker.transform.origin = Vector3(
		cos(stats.step_time * headbob_frequency * 0.5) * headbob_move_amount,
		sin(stats.step_time * headbob_frequency) * headbob_move_amount,
		0
	)
