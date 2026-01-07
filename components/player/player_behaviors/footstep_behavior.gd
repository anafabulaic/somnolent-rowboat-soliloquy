extends PlayerBehavior
class_name PlayerFootstepBehavior

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

var step_time: float = 0.0

#@export var walk_sounds: Array[AudioStream]
@export var poly_player: AudioPolyPlayer2D

var current_footstep_mat: FootstepMatResource
var ladder_footstep_mat: FootstepMatResource
var water_footstep_mat: FootstepMatResource

func init() -> void:
	water_footstep_mat = System.footstep_library[System.Footsteps.WATER]
	if not current_footstep_mat:
		current_footstep_mat = System.footstep_library[System.Footsteps.DEFAULT]
	if not ladder_footstep_mat:
		ladder_footstep_mat = System.footstep_library[System.Footsteps.LADDER]
	
func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	if (player.is_grounded() && stats.velocity.length_squared() > 0.0):
		handle_footsteps(delta)
		
	if (player.get_current_state() is PlayerClimbingState && stats.velocity.length_squared() > 0.0):
		handle_ladder(delta)
		
	if player.stats.is_in_water and stats.velocity.length_squared() > 0.0:
		var pos_with_water_y: Vector3 = player.global_position
		pos_with_water_y.y = stats.water_level
		%WaterSplash.global_position = pos_with_water_y
		#print("ENABLED")
		if !%WaterSplash.emitting:
			%WaterSplash.emitting = true
	else:
		#print("DISABLED")
		%WaterSplash.emitting = false

func handle_footsteps(delta: float) -> void:
	var horiz_length: float = (stats.velocity * Vector3(1.0,0.0,1.0)).length()
	
	step_time += delta * horiz_length
	if step_time > Game.settings.headbob_frequency:
		if Game.current_save:
			Game.current_save.steps_walked += 1
		step_time = 0.0
		play_rand_footstep(0.6)
		if player.stats.is_in_water:
			play_rand_waterstep()

func handle_ladder(delta: float) -> void:
	var vert_length: float = absf(stats.velocity.y)
	
	step_time += delta * vert_length
	if step_time > Game.settings.headbob_frequency * 0.7:
		step_time = 0.0
		play_rand_ladder()
		
func play_rand_ladder() -> void:
	var ladder_sounds := ladder_footstep_mat.footsteps
	var rand_choice: int = randi_range(0, ladder_sounds.size() - 1)

	poly_player.play_sound(ladder_sounds[rand_choice], 0.0)

func play_rand_footstep(pitch: float = 1.0) -> void:
	var walk_sounds := current_footstep_mat.footsteps
	var rand_choice: int = randi_range(0, walk_sounds.size() - 1)
	
	poly_player.play_sound(walk_sounds[rand_choice], 0.0, pitch)
		
func play_rand_waterstep() -> void:
	var water_sounds := water_footstep_mat.footsteps
	var rand_choice: int = randi_range(0, water_sounds.size() - 1)
	
	poly_player.play_sound(water_sounds[rand_choice], -2.0)
		
func play_rand_jump(pitch: float = 1.0) -> void:
	if current_footstep_mat.use_custom_jump:
		var jump_sounds := current_footstep_mat.jump_sounds
		var rand_choice: int = randi_range(0, jump_sounds.size() - 1)
	
		poly_player.play_sound(jump_sounds[rand_choice], 0.0, pitch)
		
func play_rand_waterjump() -> void:
	var water_sounds := water_footstep_mat.jump_sounds
	var rand_choice: int = randi_range(0, water_sounds.size() - 1)

	poly_player.play_sound(water_sounds[rand_choice], -2.0)

func _on_jumped() -> void:
	play_rand_footstep(0.8)
	if player.stats.is_in_water:
		play_rand_waterjump()
	step_time = 0.0

func _on_player_grounded_state_entered(previous_state_name: String, data: Dictionary) -> void:
	if previous_state_name == "PlayerFallingState" and stats.can_land and !player.locked and stats.can_move_and_slide:
		play_rand_footstep(0.8)
		if player.stats.is_in_water:
			play_rand_waterjump()
		step_time = 0.0
