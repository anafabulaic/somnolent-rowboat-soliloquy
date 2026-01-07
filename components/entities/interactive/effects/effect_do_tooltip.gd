extends InteractableEffect
class_name InteractableEffectDoTooltip

@export var text: String = "<empty>"
@export var duration: float = 3.0
@export var sound: AudioStream

func _effect() -> void:
	if !sound:
		sound = System.sound.ui_tooltip_sound
	
	SignalBus.ui_do_tooltip.emit(text, duration, sound)
