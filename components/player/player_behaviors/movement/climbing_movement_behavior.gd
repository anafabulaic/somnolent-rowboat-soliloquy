extends PlayerBehavior
class_name PlayerClimbingMovementBehavior

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	if !(player.get_current_state() is PlayerClimbingState) or stats.current_ladder == null:
		return
		
	if stats.wants_jump:
		stats.velocity = stats.current_ladder.normal * 5.0
		stats.velocity.y = 0
		
		stats.current_ladder = null
		player.set_state("PlayerFallingState")
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	if !(player.get_current_state() is PlayerClimbingState) or stats.current_ladder == null:
		return
	
	var camera_dir_no_y: Vector3 = (-player._camera_head.global_basis.z * Vector3(1, 0, 1)).normalized()
	var ladder_dot: float = camera_dir_no_y.dot(-stats.current_ladder.normal)
	
	var towards_ladder_dot: float = -player.get_wish_dir().dot(stats.current_ladder.normal)
	var side_axis: Vector3 = Vector3.UP.rotated(stats.current_ladder.normal, deg_to_rad(-90))
	var up_rotated: Vector3 = Vector3.UP.rotated(side_axis, deg_to_rad(-45))
	#var up_rotated_reverse: Vector3 = Vector3.UP.rotated(side_axis, deg_to_rad(135))
	#var camera_dot: float = player.get_camera_dir().dot(up_rotated)
	
	#DebugDraw3D.draw_line(player.global_position, player.global_position + up_rotated, Color.RED, 0.1)
	#DebugDraw3D.draw_line(player.global_position, player.global_position + up_rotated_reverse, Color.BLUE, 0.1)

	var input_dir: Vector2 = player.get_input_dir()
	var forward_move: float = -input_dir.y
	#var side_move: float = input_dir.x
	
	var wish_dir_forward: Vector3 = (player._camera_head.global_basis * Vector3(0, 0, input_dir.y)).normalized()
	var wish_dir_side: Vector3 = (player._camera_head.global_basis * Vector3(input_dir.x, 0, 0)).normalized()
	#var facing_ladder: bool = true if ladder_dot >= 0.0 else false
	var use_forward: bool = true if absf(ladder_dot) > 0.3 else false
	
	var up_wish: float = up_rotated.dot(player.get_camera_wish_dir())
	
	if player.is_on_floor() and towards_ladder_dot < 0.0:
		stats.velocity = player.get_wish_dir() * stats.climbing_speed * delta
		return
	
	if use_forward:
		#up_wish = up_rotated.dot(player.get_camera_wish_dir())
		stats.velocity = wish_dir_side * stats.climbing_speed * 0.5 * delta
		stats.velocity.y = forward_move * stats.climbing_speed * delta
	else:
		#up_wish = up_rotated.dot(player.get_camera_wish_dir())
		stats.velocity = wish_dir_forward * stats.climbing_speed * 0.5 * delta
		stats.velocity.y = forward_move * stats.climbing_speed * delta

	stats.velocity.y = up_wish * stats.climbing_speed * delta
