extends PhysicsBody3D
class_name PlayerInteractable

signal player_interact()
signal player_look_at()
signal player_look_away()

@export var can_interact: bool = false
@export var look_monitor: bool = false
@export var continuous_look: bool = false

var being_looked_at: bool = false
@warning_ignore("narrowing_conversion")
var last_frame_looked_at: int = -INF

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !look_monitor or Engine.is_editor_hint():
		return
	
	var was_looked_at := Engine.get_physics_frames() - last_frame_looked_at <= 1

	if being_looked_at and !was_looked_at:
		_on_player_look_away()

func _on_player_interact() -> void:
	if !can_interact:
		return
		
	player_interact.emit()
	on_player_interact()
	
func _on_player_look_at() -> void:
	if !look_monitor:
		return
	
	last_frame_looked_at = Engine.get_physics_frames()
	player_look_at.emit()
	
	if !continuous_look:
		var was_looked_at := Engine.get_physics_frames() - last_frame_looked_at == 1
		if !was_looked_at and !being_looked_at:
			being_looked_at = true
			on_player_look_at()
	else:
		being_looked_at = true
		
		on_player_look_at()
	
func _on_player_look_away() -> void:
	being_looked_at = false
	player_look_away.emit()
	
	on_player_look_away()

func do_interact_vfx() -> void:
	for child in get_children():
		if child is VisualInstance3D:
			var vis_instance: VisualInstance3D = child
			var old_scale: Vector3 = vis_instance.scale
			var new_scale: Vector3 = vis_instance.scale * 0.9
			
			var tween: Tween = self.create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.tween_property(vis_instance, "scale", new_scale, 0.1)
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(vis_instance, "scale", old_scale, 0.2)

func on_player_interact() -> void:
	pass

func on_player_look_at() -> void:
	pass
	
func on_player_look_away() -> void:
	pass
