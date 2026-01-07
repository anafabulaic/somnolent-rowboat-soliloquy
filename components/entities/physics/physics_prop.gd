extends RigidBody3D
class_name PhysicsProp3D

@export var sound_mat: SoundMatResource
@export var prop_gravity: float = 1.0

var sound_player: AudioStreamPlayer3D
var sliding_sound_player: AudioStreamPlayer3D

var grabbed: bool = false:
	set(value):
		do_just_grabbed()
		grabbed = value
var just_grabbed: bool = false

var real_velocity: float = 0.0

var finished: bool = true
var sliding: bool = false
var colliding: bool = false
var contact_normal: Vector3

var mute_sounds: bool = false
var mute_impact: bool = false
var mute_slide: bool = false

func _ready() -> void:
	_validate_soundmat()
	_init_sound_player()
	_init_collision()
	
	gravity_scale = prop_gravity
	contact_monitor = true
	max_contacts_reported = 2

func _validate_soundmat() -> void:
	if not sound_mat:
		if System.default_soundmat:
			push_warning(name, " has no SoundMat! Using fallback.")
			sound_mat = System.default_soundmat
		else:
			push_error("No SoundMat assigned to PhysicsProp3D ", name)
		
	if sound_mat == null or sound_mat.impacts.size() == 0:
		mute_impact = true
	if sound_mat == null or sound_mat.sliding == null:
		mute_slide = true

func _init_sound_player() -> void:
	if not sound_player:
		sound_player = AudioStreamPlayer3D.new()
		add_child(sound_player)
		
	if not sliding_sound_player:
		sliding_sound_player = AudioStreamPlayer3D.new()
		add_child(sliding_sound_player)
		
	sliding_sound_player.bus = "Foley"
	sliding_sound_player.unit_size = 5.0
	sliding_sound_player.max_polyphony = 1
	
	sound_player.bus = "Foley"
	sound_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
	sound_player.unit_size = 5.0
	sound_player.max_polyphony = 4
	
	sound_player.connect("finished", _on_audio_stream_player_3d_finished)
	
func _init_collision() -> void:
	self.collision_layer = 0
	self.collision_mask = 0
	
	self.set_collision_layer_value(2, true)
	
	self.set_collision_mask_value(1, true)
	self.set_collision_mask_value(2, true)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Game.current_scene and global_position.y < Game.current_scene.void_level:
		self.queue_free()
		return
		
	if sleeping || mute_sounds || state.get_contact_count() == 0 :
		sliding_sound_player.stop()
		return
	
	var contact_id: int = -1
		
	for i in range(state.get_contact_count()):
		if !(state.get_contact_collider_object(i) is PlayerPhysShadow):
			contact_id = i

	if contact_id == -1:
		return
	
	colliding = true
	contact_normal = state.get_contact_local_normal(contact_id)
	
	#var contact_pos: Vector3 = state.get_contact_collider_position(contact_id)
	var contact_velocity: Vector3 = state.get_contact_local_velocity_at_position(contact_id)
	#var contact_impulse: Vector3 = state.get_contact_impulse(contact_id)
	var slide_check: float = absf(linear_velocity.normalized().dot(contact_normal))

	sliding = contact_velocity.length_squared() > 1.0 && linear_velocity.length_squared() > 1.0\
	 && slide_check < 0.1
	
	if sliding && !mute_slide:
		play_slide(linear_velocity.length())
		return
	else:
		sliding_sound_player.stop()
	
	#DebugDraw3D.draw_line(state.get_contact_collider_position(0), state.get_contact_collider_position(0) + contact_impulse, Color.RED, 1.0)
	#DebugDraw3D.draw_line(state.get_contact_collider_position(0), state.get_contact_collider_position(0) + contact_normal, Color.BLUE, 1.0)

	if !finished || mute_impact:
		return

	#var contact_dot: float = contact_impulse.normalized().dot(contact_normal)
	var contact_local_velocity: float = state.get_velocity_at_local_position(state.get_contact_local_position(contact_id)).length()
	
	if contact_local_velocity > 2.0:
		play_impact(contact_local_velocity)
		#var new_config := DebugDraw3D.new_scoped_config()
		#new_config.set_no_depth_test(true)
		#DebugDraw3D.draw_square(state.get_contact_local_position(contact_id), 0.1, Color.RED, 1.0)
		#DebugDraw3D.draw_text(state.get_contact_local_position(contact_id) + (Vector3.UP * 0.2), str("%10.3f" % contact_local_velocity), 32, Color.RED, 1.0)

	

func _physics_process(delta: float) -> void:	
	pass
	
	#if velocity > 0.5 and can_collide():
		##if !is_sliding() and finished == true:
			##play_impact()
		#if is_sliding():
			#play_slide(velocity)
	
	#if colliding == true and can_collide() and is_sliding() and finished == true and just_grabbed == false:
		#play_slide(velocity)

func play_slide(vel: float) -> void:
	if (vel < 0.5 || !colliding):
		sliding_sound_player.stop()
		return
	
	sliding_sound_player.volume_db = -50 + (vel * 5)
	
	if (!sliding_sound_player.playing):
		sliding_sound_player.stream = sound_mat.sliding
		sliding_sound_player.play()
	
func play_impact(impulse: float) -> void:
	var velocity: float
	velocity = impulse

	var vol: float = -30 + (velocity * 0.5)
	
	sound_player.volume_db = clampf(vol, -40, -20.0)

	sound_player.stream = sound_mat.impacts[randi_range(0,sound_mat.impacts.size() - 1)]
	sound_player.pitch_scale = clampf(velocity * 0.25, sound_mat.impact_min_pitch, sound_mat.impact_max_pitch)
	sound_player.play()
	
	#print("velocity: ", velocity, " | volume: ", sound_player.volume_db)
	finished = false
	do_cooldown()
	
func play_hit_impact() -> void:
	sound_player.volume_db = 0
	sound_player.stream = sound_mat.impacts[randi_range(0,sound_mat.impacts.size() - 1)]
	sound_player.pitch_scale = sound_mat.impact_max_pitch
	sound_player.play()
	
	finished = false
	do_cooldown()
	
func is_sliding() -> bool:
	if abs(linear_velocity.normalized().dot(contact_normal)) < 0.1:
		return true
	else:
		return false
	
func can_collide() -> bool:
	var colliders: Array = ["StaticBody3D", "RigidBody3D"]
	
	if get_colliding_bodies().size() > 0 and get_colliding_bodies()[0].get_class() in colliders:
		return true
	else:
		return false

func _on_audio_stream_player_3d_finished() -> void:
	finished = true
	
func do_cooldown() -> void:
	await Main.wait(0.5)
	finished = true

func do_just_grabbed() -> void:
	just_grabbed = true
	await Main.wait(0.1)
	just_grabbed = false
