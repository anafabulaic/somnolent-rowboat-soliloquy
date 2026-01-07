extends Node

var settings: GameSettings = preload("res://components/settings/default_settings.tres")

func _ready() -> void:
	if not settings:
		settings = System.default_settings
	
	Input.set_use_accumulated_input(false)
	
func is_mouse_captured() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

func wait(seconds: float) -> Signal:
	return get_tree().create_timer(seconds).timeout
