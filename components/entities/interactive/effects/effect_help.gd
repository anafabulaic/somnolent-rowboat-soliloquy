extends InteractableEffect
class_name InteractableEffectHelp

func _effect() -> void:
	if Game.current_save and !Game.current_save.triggered_first_time_events:
		await Main.wait(0.2)
		Game.pause()
		SignalBus.set_submenu.emit(UIMenuManager.SubMenu.Help)
