extends UISubMenu
class_name UIHelpSubMenu

func _input(event: InputEvent) -> void:
	if Game.current_save and !Game.current_save.triggered_first_time_events and self.visible and %Return.disabled == false:
		if event is InputEventKey:
			SignalBus.set_submenu.emit(UIMenuManager.SubMenu.None)
			#SignalBus.sound_play_on_ui.emit(System.sound.ui_trinket_get, -5.0, 0.4)
			Game.unpause()
			#Game.current_save.triggered_first_time_events = true
			#Game.can_pause = true

func summon() -> void:
	if Game.current_save and !Game.current_save.triggered_first_time_events:
		#Game.can_pause = false
		%Return.text = "WAIT..."
		%Return.disabled = true
		await Main.wait(3.0)
		if self.visible and %Return.disabled == true:
			%Return.text = "PRESS ANY KEY TO CONTINUE"
			%Return.disabled = false
	else:
		%Return.text = "RETURN"
		%Return.disabled = false

func _on_return_hidden() -> void:
	if Game.current_save and !Game.current_save.triggered_first_time_events:
		SignalBus.sound_play_on_ui.emit(System.sound.ui_trinket_get, -5.0, 0.4)
		Game.current_save.triggered_first_time_events = true
