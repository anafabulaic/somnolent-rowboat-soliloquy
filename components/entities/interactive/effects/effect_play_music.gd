extends InteractableEffect
class_name InteractableEffectPlayMusic

@export var music_resource: MusicResource
@export var stop_music: bool = false

func _effect() -> void:
	if stop_music:
		SignalBus.stop_music.emit()
		return
	
	if music_resource:
		SignalBus.set_next_music.emit(music_resource)
