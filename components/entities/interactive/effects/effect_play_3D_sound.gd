extends InteractableEffect
class_name InteractableEffectPlay3DSound

@export var sound: AudioStream
@export var volume: float = -5.0
@export var pitch: float = 1.0
@export var use_random_pitch: bool = false
@export var random_pitch_min: float = 0.0
@export var random_pitch_max: float = 1.0
@export var bus: String = "UI"

enum PosMode {
	AtPlayer, ## Spawns the sound at the player.
	AtVector ## Spawns the sound at the specified position.
}

@export var position_mode: PosMode = PosMode.AtPlayer
@export var position: Vector3 = Vector3.ZERO

func _effect() -> void:
	var rand_pitch := pitch if !use_random_pitch else randf_range(random_pitch_min, random_pitch_max)
	var pos: Vector3 = position
	
	if Game.player and position_mode == PosMode.AtPlayer:
		pos = Game.player.global_position
	
	SignalBus.sound_play_3D.emit(sound, pos, volume, rand_pitch, bus)
