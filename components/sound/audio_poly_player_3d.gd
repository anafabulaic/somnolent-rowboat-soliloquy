extends AudioStreamPlayer3D
class_name AudioPolyPlayer3D

func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	
func play_sound(sound: AudioStream, vol: float = 0.0, pitch: float = 1.0, audio_bus: String = "Master") -> void:
	if !playing:
		play()
		
	var poly_playback: AudioStreamPlaybackPolyphonic = get_stream_playback()
	
	if poly_playback != null:
		poly_playback.play_stream(sound, 0.0, vol, pitch, AudioServer.PLAYBACK_TYPE_DEFAULT, audio_bus)
