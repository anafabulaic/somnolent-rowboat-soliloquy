extends UISubMenu
class_name UIStartGameSubMenu

func summon() -> void:
	if Game.current_save:
		%Warning.text = "Start a new game?\nThis will discard your current save."
	else:
		%Warning.text = "Start a new game?"

func _on_yes_pressed() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, -5.0, 1.0)
	Game.ui.menu.clear_submenu()
	Game.unpause()
	Game.start_new_game(true)

func _on_no_pressed() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, -5.0, 0.8)
	Game.ui.menu.clear_submenu()
	
func _on_hover() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_hover_sound, -5.0, 1.0)
