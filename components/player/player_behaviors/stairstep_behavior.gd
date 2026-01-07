extends PlayerBehavior
class_name PlayerStairstepBehavior

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

@export var stairs_below_raycast: RayCast3D
@export var stairs_ahead_raycast: RayCast3D
@export var camera_smooth: Node3D

var snapped_to_stairs_last_frame: bool = false
@warning_ignore("narrowing_conversion")
var last_frame_was_on_floor: int = -INF

var saved_camera_global_pos: Vector3 = Vector3.ZERO

var do_smooth: bool = false

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	if player.is_grounded(): 
		last_frame_was_on_floor = Engine.get_physics_frames()
	
	if (player._physshadow.active):
		slide_camera_smooth_back_to_origin(delta)
		return
	
	if not snap_up_to_stairs_check(delta):
		stats.can_move_and_slide = true
		snap_down_to_stairs_check()
	else:
		stats.can_move_and_slide = false
		stats.can_land = true
		
	slide_camera_smooth_back_to_origin(delta)
	#if (camera_smooth.position.y == 0 && do_smooth):
		#do_smooth = false
	
func is_surface_too_steep(normal: Vector3) -> bool:
	#print(rad_to_deg(normal.angle_to(Vector3.UP)))
	return normal.angle_to(Vector3.UP) > player.get_floor_angle()

func snap_down_to_stairs_check() -> void:
	var did_snap := false
	
	stairs_below_raycast.force_raycast_update()
	
	var floor_below: bool = stairs_below_raycast.is_colliding() and not is_surface_too_steep(stairs_below_raycast.get_collision_normal())
	var was_on_floor_last_frame := Engine.get_physics_frames() - last_frame_was_on_floor == 1

	if not player.is_grounded() and stats.velocity.y <= 0 and (was_on_floor_last_frame or snapped_to_stairs_last_frame) and floor_below:
		var body_test_result := KinematicCollision3D.new()
		if player.test_move(player.global_transform, Vector3(0,-stats.max_step_height,0), body_test_result):
			save_camera_pos_for_smoothing()
			var translate_y := body_test_result.get_travel().y
			player.position.y += translate_y
			player.apply_floor_snap()
			did_snap = true
			stats.can_land = false
		else:
			stats.can_land = true
	snapped_to_stairs_last_frame = did_snap

func snap_up_to_stairs_check(delta: float) -> bool:
	if not player.is_grounded() and not snapped_to_stairs_last_frame: 
		return false
		
	var expected_move_motion := stats.velocity * Vector3(1,0,1)
	var MAX_STEEPNESS: float = stats.max_walk_slope
	var MAX_STEP_HEIGHT: float = stats.max_step_height
	
	if player.is_on_wall():
		for collision in player.get_slide_collision_count():
			if player.get_slide_collision(collision).get_angle() > deg_to_rad(MAX_STEEPNESS) and\
			 player.get_slide_collision(collision).get_position().y - player.global_position.y > MAX_STEP_HEIGHT:
				var wall_position := player.get_slide_collision(collision).get_position()
				wall_position.y = player.global_position.y
				var distance := player.global_position.distance_to(wall_position) * 1
				expected_move_motion = (expected_move_motion + (player.get_wall_normal() * distance * Vector3(1,0,1)))
		expected_move_motion = expected_move_motion * delta
	else:
		stats.can_land = true
		expected_move_motion = expected_move_motion * delta
			
	var step_pos_with_clearance := player.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))

	var down_check_result := KinematicCollision3D.new()
	
	if player.test_move(step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT * 2, 0), down_check_result):
		var step_height := ((step_pos_with_clearance.origin + down_check_result.get_travel()) - player.global_position).y
		
		if step_height > MAX_STEP_HEIGHT + 0.5 or step_height <= 0.01 or (down_check_result.get_position() - player.global_position).y > MAX_STEP_HEIGHT:
			stats.can_land = true
			return false
		
		stairs_ahead_raycast.global_position = down_check_result.get_position() + Vector3(0, MAX_STEP_HEIGHT, 0) + expected_move_motion.normalized() * 0.1
		stairs_ahead_raycast.force_raycast_update()
		
		if stairs_ahead_raycast.is_colliding() and not is_surface_too_steep(stairs_ahead_raycast.get_collision_normal()):
			save_camera_pos_for_smoothing()
			player.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			player.apply_floor_snap()
			snapped_to_stairs_last_frame = true
			stats.can_land = false
			return true
	return false

func save_camera_pos_for_smoothing() -> void:
	if !do_smooth:
		do_smooth = true
		saved_camera_global_pos = camera_smooth.global_position
		#print("Saved at ", saved_camera_global_pos.y, " | ", camera_smooth.global_position.y)
		
func slide_camera_smooth_back_to_origin(delta: float) -> void:
	if !do_smooth:
		return
		
	camera_smooth.global_position.y = saved_camera_global_pos.y
	camera_smooth.position.y = clampf(camera_smooth.position.y, -0.5, 0.5)
	
	var move_amount: float = max((stats.velocity.length() / 2) * delta, stats.walk_speed / 100 * delta)
	#move_amount = 3 * delta
	#move_amount = (stats.velocity.length() / 2) * delta
	

	camera_smooth.position.y = move_toward(camera_smooth.position.y, 0.0, move_amount)
	saved_camera_global_pos = camera_smooth.global_position
	
	#var new_transform: Transform3D = Transform3D(Basis.IDENTITY, saved_camera_global_pos)
	#DebugDraw3D.draw_position(new_transform)
	
	#player.reset_physics_interpolation()

	if camera_smooth.position.y == 0.0:
		do_smooth = false
