extends PlayerBehavior
class_name PlayerAirMovementBehavior

# @onready var player: Player = self.owner

var velocity: Vector3
var wish_velocity: Vector3

var air_accel: float
var air_control: float
var air_limit: float

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	if player.is_grounded():
		return
	
	update_variables()
	
	velocity = air_accelerate(velocity, wish_velocity, air_accel, air_control, delta)
	
	if (player.is_on_wall()):
		velocity = clip_velocity(velocity, player.get_wall_normal(), 1, delta)
	
	stats.velocity = velocity

func update_variables() -> void:
	velocity = stats.velocity
	wish_velocity = stats.wish_dir * stats.wish_speed
	
	air_accel = stats.air_accel
	air_control = stats.air_control_cap
	air_limit = stats.air_speed_limit

func air_accelerate(prev_velocity: Vector3, wish_vel: Vector3, accel: float, cap: float, delta: float) -> Vector3:
	var wish_dir: Vector3 = wish_vel.normalized()

	var wish_speed: float = prev_velocity.dot(wish_dir)
	var capped_speed: float = minf(wish_vel.length(), cap)
	var add_speed: float = capped_speed - wish_speed
	
	if ( add_speed <= 0):
		return prev_velocity
	
	var accel_speed: float = accel * wish_vel.length() * delta
	
	accel_speed = minf(accel_speed, add_speed)
	
	var new_vel: Vector3 = prev_velocity + (accel_speed * wish_dir)
	#var new_vel_length: float = (new_vel * Vector3(1,0,1)).length()
	#
	#if (new_vel_length > stats.air_speed_limit):
		#new_vel = (new_vel * Vector3(1,0,1)).normalized() * stats.air_speed_limit
		#new_vel.y = prev_velocity.y
	
	return new_vel

func clip_velocity(prev_velocity: Vector3, normal: Vector3, overbounce: float, delta: float) -> Vector3:
	var backoff: float = prev_velocity.dot(normal) * overbounce
	
	if backoff >= 0: return prev_velocity
	
	var change: Vector3 = normal * backoff
	prev_velocity -= change
	
	var adjust: float = prev_velocity.dot(normal)
	if adjust < 0.0:
		prev_velocity -= normal * adjust
		
	return prev_velocity
