extends InteractableEffect
class_name InteractableEffectPrintDebug

func _effect() -> void:
	LimboConsole.info("Debug success!")
	print("Debug success!")
