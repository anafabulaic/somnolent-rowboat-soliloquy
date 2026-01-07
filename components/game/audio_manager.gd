extends Node
class_name AudioManager

@export var ui_audio_player: AudioPolyPlayer2D

@export var current_music_player: AudioStreamPlayer2D
#@export var next_music_player: AudioStreamPlayer2D

var current_music: MusicResource
var next_music: MusicResource

var fade_into_current_song: bool = false
var fade_from_current_song: bool = false

var transition: float = 0.0
var default_trans_speed: float = 1.0
var trans_speed_mult: float = 1.0

func _ready() -> void:
	SignalBus.sound_play_2D.connect(ui_audio_player.play_sound)
	SignalBus.sound_play_on_ui.connect(play_sound_simple)
	
	SignalBus.set_next_music.connect(set_next_music)
	SignalBus.stop_music.connect(stop_music)
	
func _process(delta: float) -> void:
	if fade_from_current_song:
		transition -= delta * default_trans_speed * trans_speed_mult
		transition = clampf(transition, 0.0, 1.0)
		
		current_music_player.volume_linear = transition
		
		if transition <= 0.0:
			transition = 0.0
			
			if next_music:
				fade_from_current_song = false
				fade_into_current_song = true
				
				current_music_player.stream = next_music.song
				current_music_player.playing = true
				trans_speed_mult = next_music.transition_speed_mult
				current_music = next_music
				next_music = null
			else:
				current_music_player.playing = false
				current_music_player.stream = null
				current_music = null
				trans_speed_mult = 1.0
	elif fade_into_current_song:
		transition += delta
		transition = clampf(transition, 0.0, 1.0)
		
		current_music_player.volume_linear = transition
		
		if transition >= 1.0:
			transition = 1.0
			
			fade_into_current_song = false

func set_next_music(next: MusicResource) -> void:
	if !next.song:
		return
	
	if current_music == null:
		current_music = next
		transition = 0.0
		current_music_player.volume_linear = transition
		current_music_player.stream = next.song
		current_music_player.playing = true
		trans_speed_mult = next.transition_speed_mult
		
		fade_from_current_song = false
		fade_into_current_song = true
	elif current_music != next:
		next_music = next
		
		fade_from_current_song = true
		fade_into_current_song = false
	else:
		fade_from_current_song = false
		fade_into_current_song = true
		trans_speed_mult = current_music.transition_speed_mult
		
func stop_music() -> void:
	if current_music:
		fade_from_current_song = true

func play_sound_simple(sound: AudioStream, vol: float = 0.0, pitch: float = 1.0) -> void:
	ui_audio_player.play_sound(sound, vol, pitch)
