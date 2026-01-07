extends UISubMenu
class_name UIQuitGameSubMenu

func summon() -> void:
	pass

func _on_yes_pressed() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, -5.0, 1.0)
	get_tree().quit()

func _on_no_pressed() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, -5.0, 0.8)
	Game.ui.menu.clear_submenu()
	
func _on_hover() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_hover_sound, -5.0, 1.0)
