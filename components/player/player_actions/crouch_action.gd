extends PlayerAction
class_name PlayerCrouchAction

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

@export var collider: CollisionShape3D
#@export var camera_holder: Node3D
@export var collision_shape: BoxShape3D

var original_height: float
var original_camera_height: float

var was_crouched: bool = false
var is_crouched: bool = false

func init() -> void:
	original_height = collision_shape.size.y
	original_camera_height = stats.camera_height

func handle_input(event: InputEvent) -> void:
	pass
	
func update_physics(delta: float) -> void:
	do_crouch(delta)
	
func can_use() -> bool:
	return true
	
func execute() -> void:
	pass

func do_crouch(delta: float) -> void:
	was_crouched = is_crouched
	
	if (stats.wants_crouch):
		is_crouched = true
	elif (can_uncrouch()):
		is_crouched = false
		
	var translate_y: float = 0.0
	var crouch_check: bool = (was_crouched != is_crouched) && !player.is_grounded()
	
	if (crouch_check):
		translate_y = stats.crouch_translate if is_crouched else -stats.crouch_translate
		player.move_and_collide(Vector3.UP * translate_y)
		if stats.touching_physics:
			var phys: PlayerPhysShadow = player._physshadow
			phys.global_transform = phys.global_transform.translated(Vector3.UP * translate_y)
		
	var desired_head_height: float = original_camera_height - stats.crouch_translate if is_crouched else original_camera_height
	var crouch_translate_lerp: float = move_toward(stats.desired_camera_height, desired_head_height, delta * stats.crouching_speed)
	
	if (crouch_check):
		stats.desired_camera_height = desired_head_height
	else:
		stats.desired_camera_height = crouch_translate_lerp
		
	var desired_height: float = original_height - stats.crouch_translate if is_crouched else original_height	
	player.set_hull_height(desired_height)
	
	stats.is_crouched = is_crouched
	
	if is_crouched:
		stats.wish_speed = stats.crouch_speed

func can_uncrouch() -> bool:
	var result := KinematicCollision3D.new()
	
	if (!is_crouched):
		return true
	
	# Don't uncrouch if we're in mid-air and there's something directly below us that we'll instantly translate to if we uncrouch.
	if (!player.is_grounded() && is_crouched):
		player.test_move(player.global_transform, Vector3.DOWN * stats.crouch_translate, result)
		return result.get_remainder().length_squared() == 0
	else:
		return !player.test_move(player.global_transform, Vector3(0,stats.crouch_translate,0), null, 0.001, true, 2)
