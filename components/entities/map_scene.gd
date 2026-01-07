extends Node3D
class_name MapScene

@export var map_name: String
@export var environment: WorldEnvironment
@export var spawnpoints: Array[MapSpawnPoint] = []
@export var void_level: float = -100

enum VoidBehavior {
	Awaken, ## Wakes the player up when they fall below the void level
	Wrap, ## Wraps the player around to the top of the level.
}

@export var void_behavior: VoidBehavior = VoidBehavior.Awaken

@export var is_sub_world: bool = false ## should this be counted as its own world for player statistics?

@export var use_world_bound: bool = false
@export var use_world_bound_x: bool = false
@export var use_world_bound_y: bool = false
@export var use_world_bound_z: bool = false
@export var world_bounds: Vector3

var doing_fog: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !spawnpoints.is_empty():
		return
	else:
		var empty_string := str("Spawnpoint list for ", map_name, " is empty. Trying to find spawnpoints in scene itself.")
		
		LimboConsole.warn(empty_string)
		print(empty_string)
		
	var spawn_points := get_tree().get_nodes_in_group("Spawnpoints")
	
	if spawn_points.is_empty():
		var cant_find_string := str("Couldn't find a spawnpoint for ", map_name)
		
		LimboConsole.warn(cant_find_string)
		print(cant_find_string)
		
		var default_spawnpoint: MapSpawnPoint = MapSpawnPoint.new()
		default_spawnpoint.position = Vector3.ZERO
		
		add_child(default_spawnpoint)
		spawnpoints.append(default_spawnpoint)
		
		return
	
	var new_array: Array[MapSpawnPoint] = []
	for spawn_point in spawn_points:
		if spawn_point is MapSpawnPoint and spawn_point != null:
			new_array.append(spawn_point)
	
	var find_string := str("Found spawnpoints for ", map_name, ": ", new_array.size())
	LimboConsole.info(find_string)
	print(find_string)
		
	spawnpoints = new_array

## TODO: make this not ugly later

func _physics_process(delta: float) -> void:
	if Game.player and Game.current_scene and use_world_bound and !doing_fog:
		var player: Player = Game.player
		
		var did_fog_already: bool = false
		
		if abs(player.global_position.x) > world_bounds.x and use_world_bound_x and !did_fog_already:
			did_fog_already = true
			do_fog()
		if abs(player.global_position.z) > world_bounds.z and use_world_bound_z and !did_fog_already:
			did_fog_already = true
			do_fog()
		if abs(player.global_position.y) > world_bounds.y and use_world_bound_y and !did_fog_already:
			did_fog_already = true
			do_fog()
			
func do_fog() -> void:
	if Game.player and Game.current_scene and Game.current_scene.environment and Game.current_scene.environment.environment:
		var env: Environment = Game.current_scene.environment.environment
		
		doing_fog = true
		
		var tween := self.create_tween()
		var original_fog: float = env.fog_depth_end
		var original_sky_affect: float = env.fog_sky_affect
		tween.tween_property(env, "fog_sky_affect", 1.0, 0.5)
		tween.parallel().tween_property(env, "fog_depth_end", 0.1, 0.5)
		tween.tween_callback(wrap_player_pos)
		tween.tween_property(env, "fog_depth_end", 0.1, 0.1)
		tween.tween_property(env, "fog_sky_affect", original_sky_affect, 0.5)
		tween.parallel().tween_property(env, "fog_depth_end", original_fog, 0.5)
		tween.tween_callback(undoing_fog)
		
func wrap_player_pos() -> void:
	if Game.player and Game.current_scene and use_world_bound:
		
		var player: Player = Game.player
		if abs(player.global_position.x) > world_bounds.x and use_world_bound_x:
			player.global_position.x *= -1.0
			player.global_position.x = clampf(player.global_position.x, -world_bounds.x, world_bounds.x)
		if abs(player.global_position.y) > world_bounds.y and use_world_bound_y:
			player.global_position.y *= -1.0
			player.global_position.y = clampf(player.global_position.y, -world_bounds.y, world_bounds.y)
		if abs(player.global_position.z) > world_bounds.z and use_world_bound_z:
			player.global_position.z *= -1.0
			player.global_position.z = clampf(player.global_position.z, -world_bounds.z, world_bounds.z)
			

func undoing_fog() -> void:
	doing_fog = false
