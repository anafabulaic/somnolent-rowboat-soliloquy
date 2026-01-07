extends InteractableEffect
class_name MapPlayerTeleport

@export var destination: Node3D
@export var transition_type: TransitionEffectResource
@export var transition_duration: float = 0.0

@export var play_sound: bool = false
@export var teleport_sound: AudioStream

func _effect() -> void:
	if !Game.player:
		return
		
	if play_sound and teleport_sound:
		SignalBus.sound_play_on_ui.emit(teleport_sound, 0.0, 1.0)
	
	SignalBus.ui_do_transition.emit(transition_type, transition_duration, false)
	
	await SignalBus.transition_captured_screen
	
	Game.reset_player()
	Game.set_player_transform(destination.global_transform)
