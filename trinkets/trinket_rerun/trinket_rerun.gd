extends Trinket
class_name TrinketRerun

@export var rewind_sound: AudioStream
@export var transition: TransitionEffectResource
@export_file() var level_path: String
@export var duration: float = 2.0

func can_use() -> bool:
	if Game.current_scene and Game.player and Game.current_scene.map_name != "srs_site433_dream" and !Game.is_awake:
		return true
	else: return false

func execute() -> void:
	SignalBus.sound_play_on_ui.emit(rewind_sound, 0.0, 0.6)
	SignalBus.ui_do_transition.emit(transition, duration, true)
	SignalBus.stop_music.emit()

	await SignalBus.transition_captured_screen

	Game.load_scene(level_path, "statues_area")
