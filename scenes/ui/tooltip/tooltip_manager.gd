extends VBoxContainer
class_name UIToolTipManager

@export var tooltip_scene: PackedScene

func _ready() -> void:
	SignalBus.ui_do_tooltip.connect(make_tooltip)
	SignalBus.ui_clear_tooltips.connect(clear_tooltips)

func make_tooltip(text: String, expiration: float, sound: AudioStream) -> void:
	var tooltip: UIToolTip = tooltip_scene.instantiate()
	tooltip.text = text
	tooltip.expiration_time = expiration
	
	add_child(tooltip)
	move_child(tooltip, 0)
	
	if !sound:
		sound = System.sound.ui_tooltip_sound
		
	SignalBus.sound_play_on_ui.emit(sound, 0.0, randf_range(0.6, 1.0))

func clear_tooltips() -> void:
	for child in get_children():
		if child is UIToolTip:
			child.queue_free()
