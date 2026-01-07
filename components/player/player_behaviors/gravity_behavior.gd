extends PlayerBehavior
class_name PlayerGravityBehavior

# @onready var player: Player = self.owner

func physics_update(delta: float) -> void:
	var velocity: Vector3 = stats.velocity
	var gravity: Vector3 = stats.gravity * stats.gravity_modifier
	
	velocity = apply_gravity(velocity, gravity, delta)
	
	stats.velocity = velocity
	
func apply_gravity(velocity: Vector3, gravity: Vector3, delta: float) -> Vector3:
	velocity += gravity * 0.5 * delta
	return velocity
