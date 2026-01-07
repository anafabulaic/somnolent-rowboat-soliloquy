extends UISubMenu
class_name UITrinketSubMenu

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_trinkets_quickmenu"):
		if !Game.current_scene or LimboConsole.is_open(): return

		if Game.is_paused and Game.ui.menu.current_submenu == UIMenuManager.SubMenu.Trinkets:
			SignalBus.sound_play_on_ui.emit(System.sound.ui_tooltip_sound, -5.0, 0.5)
			Game.unpause()
		elif Game.can_pause and !Game.get_awake():
			if !Game.is_paused:
				SignalBus.sound_play_on_ui.emit(System.sound.ui_tooltip_sound, -5.0, 0.4)
			Game.pause()
			Game.ui.menu.set_submenu(UIMenuManager.SubMenu.Trinkets)


func _on_return_pressed() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, 0.0, 0.8)
	Game.ui.menu.clear_submenu()

func _on_return_hover() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_hover_sound, 0.0, 1.0)
