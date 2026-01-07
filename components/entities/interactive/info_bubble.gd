@tool

extends PlayerInteractable
class_name MapInfoBubble

@export var label: Label3D
@export_multiline var label_text: String:
	set(value):
		label_text = value
		_on_text_change()
	get:
		return label_text

func _on_text_change() -> void:
	if !Engine.is_editor_hint():
		return
	
	if label:
		label.text = label_text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	super._ready()
	
	self.scale = Vector3.ONE

	can_interact = true
	look_monitor = true
	label.visible = false
	label.text = label_text
	
func do_interact_vfx() -> void:
	var vis_instance: Node3D = self
	var old_scale: Vector3 = vis_instance.scale
	var new_scale: Vector3 = vis_instance.scale * 0.9
	
	var tween: Tween = self.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(vis_instance, "scale", new_scale, 0.1)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(vis_instance, "scale", old_scale, 0.2)

func on_player_interact() -> void:
	do_interact_vfx()
	SignalBus.do_interact_lesser_error.emit()

func on_player_look_at() -> void:
	label.visible = true
	
func on_player_look_away() -> void:
	label.visible = false
