extends UISubMenu
class_name UILoadGameSubMenu

func summon() -> void:
	if Game.current_save:
		%Warning.text = "Continue from saved game?"
		
		var since: float = Time.get_unix_time_from_system() - Game.current_save.last_save_unix_time
		var since_string: String = Game.current_save.format_time(since)

		%Warning.text += str("\nLast saved: ", since_string, "ago.")
	else:
		Game.ui.menu.clear_submenu()

func _on_yes_pressed() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, -5.0, 1.0)
	Game.ui.menu.clear_submenu()
	Game.unpause()
	Game.start_new_game(false)

func _on_no_pressed() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, -5.0, 0.8)
	Game.ui.menu.clear_submenu()
	
func _on_hover() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_hover_sound, -5.0, 1.0)
