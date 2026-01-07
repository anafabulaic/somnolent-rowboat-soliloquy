extends InteractableEffect
class_name MapPlayerLevelChange

@export_file("*.tscn") var level: String = "res://maps/"
@export var spawnpoint: String
@export var transition_type: TransitionEffectResource
@export var transition_duration: float = 0.0

@export var play_sound: bool = false

@export var teleport_sound: AudioStream

func _effect() -> void:
	if !Game.player:
		return
	
	if play_sound and teleport_sound:
			SignalBus.sound_play_on_ui.emit(teleport_sound, 0.0, 1.0)
	
	SignalBus.ui_do_transition.emit(transition_type, transition_duration, true)
	SignalBus.stop_music.emit()
	
	await SignalBus.transition_captured_screen
	
	Game.load_scene(level, spawnpoint)
