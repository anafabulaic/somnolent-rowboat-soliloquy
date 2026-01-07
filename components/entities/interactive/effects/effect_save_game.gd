extends InteractableEffect
class_name InteractableEffectSaveGame

func _effect() -> void:
	SignalBus.save_game.emit()
