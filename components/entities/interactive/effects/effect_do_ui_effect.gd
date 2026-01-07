extends InteractableEffect
class_name InteractableEffectDoUIEffect

enum Effect {
	lesser_error,
	error,
	bounce
}

@export var ui_effect: Effect

func _effect() -> void:
	match ui_effect:
		Effect.lesser_error:
			SignalBus.do_interact_lesser_error.emit()
		Effect.error:
			SignalBus.do_interact_error.emit()
		Effect.bounce:
			SignalBus.do_interact_bounce.emit()
