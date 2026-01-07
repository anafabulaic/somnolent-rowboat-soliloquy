extends Area3D
class_name MapWaterVolume

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
	
func on_body_entered(body: Node3D) -> void:
	if body is Player:
		var player: Player = body
		player.stats.is_in_water = true
		var aabb: AABB = self.global_transform * Util.get_aabb(self)
		var water_level: float = aabb.end.y
		var player_pos: Vector3 = Vector3(player.global_position.x, water_level, player.global_position.z)
		
		player.stats.water_level = water_level	
		
		SignalBus.spawn_particles.emit(System.effect_water, player_pos)
	elif body is RigidBody3D:
		var rigidbody: RigidBody3D = body
		var aabb: AABB = self.global_transform * Util.get_aabb(self)
		var water_level: float = aabb.end.y
		var rb_pos: Vector3 = Vector3(rigidbody.global_position.x, water_level, rigidbody.global_position.z)
		
		SignalBus.spawn_particles.emit(System.effect_water, rb_pos)
	
func on_body_exited(body: Node3D) -> void:
	if body is Player:
		var player: Player = body
		player.stats.is_in_water = false
		var aabb: AABB = self.global_transform * Util.get_aabb(self)
		var water_level: float = aabb.end.y
		var player_pos: Vector3 = Vector3(player.global_position.x, water_level, player.global_position.z)
		
		player.stats.water_level = -999

		SignalBus.spawn_particles.emit(System.effect_water, player_pos)
	elif body is RigidBody3D:
		var rigidbody: RigidBody3D = body
		var aabb: AABB = self.global_transform * Util.get_aabb(self)
		var water_level: float = aabb.end.y
		var rb_pos: Vector3 = Vector3(rigidbody.global_position.x, water_level, rigidbody.global_position.z)
		
		SignalBus.spawn_particles.emit(System.effect_water, rb_pos)
