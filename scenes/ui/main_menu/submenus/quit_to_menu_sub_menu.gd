extends UISubMenu
class_name UIQuitToMenuSubMenu

func summon() -> void:
	if Game.current_scene:
		%Warning.text = "Quit to main menu?"
		
		if Game.current_save:
			if Game.current_save.last_save_unix_time == 0:
				%Warning.text += str("\nYou haven't saved yet.")
			else:
				var since: float = Time.get_unix_time_from_system() - Game.current_save.last_save_unix_time
				var since_string: String = Game.current_save.format_time(since)
			
				%Warning.text += str("\nLast saved: ", since_string, "ago.")

func _on_yes_pressed() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, -5.0, 1.0)
	Game.ui.menu.clear_submenu()
	Game.unload_game()

func _on_no_pressed() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, -5.0, 0.8)
	Game.ui.menu.clear_submenu()
	
func _on_hover() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_hover_sound, -5.0, 1.0)
