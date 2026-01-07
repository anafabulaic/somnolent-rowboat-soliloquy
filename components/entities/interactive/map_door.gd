extends PlayerInteractable
class_name MapDoor

signal on_opened
signal on_closed

@export var door_speed: float = 2.0
@export var locked: bool = false

@export_group("Sounds")
@export var open_sound: AudioStream
@export var closed_sound: AudioStream
@export var locked_sound: AudioStream

@export_group("Dependencies")
@export var door_model: Node3D
@export var audio_player: AudioPolyPlayer3D

var default_trans: Transform3D
var default_viz_trans: Transform3D

var box_shape: BoxShape3D

var opened: bool = false
var wants_transition: bool = false
var forced: bool = false
var reverse: bool = true

var progress_to_open: float = 0.0

func _ready() -> void:
	super._ready()
	
	default_trans = self.transform
	default_viz_trans = door_model.transform
	
	var box_aabb := Util.get_aabb(self)
	var new_box := BoxShape3D.new()
	new_box.size = box_aabb.size
	#new_box.margin = 0.1
	box_shape = new_box
	
	init_collider()

func init_collider() -> void:
	self.collision_layer = 0
	self.collision_mask = 0
	
	self.set_collision_layer_value(1, true)
	self.set_collision_layer_value(4, true)
	
	self.set_collision_mask_value(1, true)
	self.set_collision_mask_value(2, true)
	self.set_collision_mask_value(32, true)

func _process(delta: float) -> void:
	pass
	
	if wants_transition:
		if opened:
			do_transition(delta, false)
		elif !opened:
			do_transition(delta, true)
	
func on_player_interact() -> void:
	var cam := Game.player.get_camera_dir() * Vector3(1,0,1)
	var fwd := default_trans.basis.x * Vector3(1,0,1)
	var open_dir := cam.dot(fwd)
	#print(cam.dot(fwd))
	
	#DebugDraw3D.draw_arrow_ray(global_position, fwd, 1.0, Color.BLUE, 0.5, false, 0.5)
	
	if !wants_transition and (!locked || (locked and opened)):
		wants_transition = true
		
		if !forced:
			var open_pitch: float = 1.1 if opened else 1.4
			audio_player.play_sound(open_sound, -10, open_pitch)
			SignalBus.do_interact_bounce.emit()
		
		if !opened:
			if open_dir >= 0.0:
				reverse = false
			elif open_dir < 0.0:
				reverse = true
				
		if locked and opened:
			forced = true
	elif locked and !opened:
		if open_dir >= 0.0:
			reverse = false
		elif open_dir < 0.0:
			reverse = true
		
		audio_player.play_sound(locked_sound, -10, 1.0)
		do_interact_vfx()
		SignalBus.do_interact_error.emit()

func do_transition(delta: float, do_open: bool) -> void:
	var open_mult: int = 1 if do_open else -1
	var reverse_mult: int = 1 if !reverse else -1

	self.transform = default_trans.rotated_local(Vector3.UP, deg_to_rad(90.0 * progress_to_open * reverse_mult))
	#self.rotation_degrees.y = lerpf(0, 90.0 * reverse_mult, progress_to_open)
	
	var progress_delta: float = progress_to_open + (delta * door_speed * open_mult)
	
	# reverses the door if something's in the way.
	if !forced and\
	opened and\
	(progress_to_open < 0.9 and progress_to_open > 0.1) and\
	check_intersect(default_trans.rotated_local(Vector3.UP, deg_to_rad(90.0 * progress_delta * reverse_mult))):
		opened = do_open
		forced = true
		return
	
	#print(opened, " | ", reverse, " | ", progress_to_open)
	
	progress_to_open = progress_delta
	
	var progress_check: bool = progress_to_open >= 1.0 if do_open else progress_to_open <= 0.0
	
	if progress_check:
		progress_to_open = 1.0 if do_open else 0.0
		wants_transition = false
		opened = do_open
		forced = false
		
		var close_pitch: float = 1.8 if opened else 1.2
		audio_player.play_sound(closed_sound, -10, close_pitch)

func check_intersect(trans: Transform3D) -> bool:
	var phys_param := PhysicsShapeQueryParameters3D.new()
	phys_param.shape = box_shape
	phys_param.shape_rid = box_shape.get_rid()
	phys_param.transform = trans.translated_local(box_shape.size / 2)
	
	phys_param.collision_mask = (1 << 1) | (1 << 31) ## Only includes layers 2 and 32, which correspond to rigidbodies and players.
	phys_param.exclude = [self.get_rid()]

	#DebugDraw3D.draw_box(phys_param.transform.origin, phys_param.transform.basis.get_rotation_quaternion(), box_shape.size, Color.RED, true)
	
	var space := get_world_3d().direct_space_state
	var result := space.intersect_shape(phys_param, 8)
	var intersecting := false
	
	#print(phys_param.exclude)
	
	for col in result:
		#if col["collider"] is StaticBody3D:
			#var static_body: StaticBody3D = col["collider"]
			#print(static_body.get_parent().name)
		#
		if col["collider"] is Player or col["collider"] is RigidBody3D:
			intersecting = true
			
	return intersecting

func do_interact_vfx() -> void:
	var vis_instance: Node3D = door_model
	var reverse_mult: int = -1 if reverse else 1

	#var old_trans: Transform3D = vis_instance.transform
	var new_trans: Transform3D = default_viz_trans.rotated(Vector3.UP, deg_to_rad(2 * reverse_mult))
	var tween: Tween = self.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(vis_instance, "transform", new_trans, 0.1)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(vis_instance, "transform", default_viz_trans, 0.2)
