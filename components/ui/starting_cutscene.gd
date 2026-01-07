extends Control
class_name StartingCutscene

signal done

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		destroy()

func _ready() -> void:
	fade_in()

func fade_in() -> void:
	var tween := self.create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 2.0).set_delay(1.0)
	tween.tween_property(self, "modulate", Color.BLACK, 2.0).set_delay(3.0)
	tween.tween_callback(destroy)

func destroy() -> void:
	done.emit()
	self.queue_free()
