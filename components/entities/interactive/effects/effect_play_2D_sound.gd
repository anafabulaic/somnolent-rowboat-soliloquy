extends InteractableEffect
class_name InteractableEffectPlay2DSound

@export var sound: AudioStream
@export var volume: float = -5.0
@export var pitch: float = 1.0
@export var use_random_pitch: bool = false
@export var random_pitch_min: float = 0.0
@export var random_pitch_max: float = 1.0
@export var bus: String = "UI" ## This shit does not work because AudioStreamPolyphonic ignorees the bus for some reason!!!!!!!

func _effect() -> void:
	var rand_pitch := pitch if !use_random_pitch else randf_range(random_pitch_min, random_pitch_max)
	
	SignalBus.sound_play_on_ui.emit(sound, volume, rand_pitch)
