extends PlayerBehavior
class_name PlayerGroundMovementBehavior

# @onready var player: Player = self.owner

var velocity: Vector3
var wish_velocity: Vector3

var ground_accel: float
var speed_cap: float

var ground_friction: float
var ground_decel: float

func init() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
		
func physics_update(delta: float) -> void:
	if !player.is_grounded():
		return
	
	update_variables()
	
	velocity = apply_friction(velocity, ground_friction, ground_decel, delta)
	velocity = accelerate(velocity, wish_velocity, ground_accel, speed_cap, delta)
	
	stats.velocity = velocity

func update_variables() -> void:
	velocity = stats.velocity	
	wish_velocity = stats.wish_dir * stats.wish_speed

	ground_accel = stats.ground_accel
	speed_cap = stats.speed_cap

	ground_friction = stats.ground_friction
	ground_decel = stats.ground_decel

func apply_friction(prev_velocity: Vector3, friction: float, decel: float, delta: float) -> Vector3:
	var control: float  = maxf(prev_velocity.length(), decel)
	var drop: float      = control * friction * delta
	var new_speed: float = maxf(prev_velocity.length() - drop, 0.0)
	
	if (prev_velocity.length() > 0.0):
		new_speed /= prev_velocity.length()
		
	return prev_velocity * new_speed	
	
func accelerate(prev_velocity: Vector3, wish_vel: Vector3, accel: float, cap: float, delta: float) -> Vector3:
	var wish_dir: Vector3 = wish_vel.normalized()
	var wish_speed: float = wish_vel.length()

	var current_speed: float = prev_velocity.dot(wish_dir)
	var addSpeed: float =     clampf(wish_speed - current_speed, 0.0, cap)
	
	if ( addSpeed <= 0):
		return prev_velocity
	
	var accelSpeed: float = accel * wish_speed * delta
	
	accelSpeed = minf(accelSpeed, addSpeed)
	
	return prev_velocity + accelSpeed * wish_dir
