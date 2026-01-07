extends Node
class_name EffectsManager

func _ready() -> void:
	SignalBus.spawn_particles.connect(spawn_particles)
	SignalBus.sound_play_3D.connect(spawn_temporary_sound)
	SignalBus.sound_play_3D_simple.connect(spawn_temporary_sound_simple)

func spawn_particles(particle_scene: PackedScene, pos: Vector3) -> void:
	var new_scene := particle_scene.instantiate()
	new_scene.position = pos
	add_child(new_scene)

func spawn_temporary_sound_simple(sound: AudioStream, pos: Vector3) -> void:
	spawn_temporary_sound(sound, pos)

func spawn_temporary_sound(sound: AudioStream, pos: Vector3, vol: float = 0.0, pitch: float = 1.0, bus: String = "Master") -> void:
	if !sound:
		return
	
	var new_sound: TemporarySound3D = TemporarySound3D.new()
	
	new_sound.stream = sound
	new_sound.position = pos
	new_sound.volume_db = vol
	new_sound.pitch_scale = pitch
	new_sound.bus = bus
	
	add_child(new_sound)
