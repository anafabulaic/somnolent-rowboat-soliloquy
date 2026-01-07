extends Control
class_name UIShaderStack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.set_shaders_visible.connect(set_enabled)
	self.visible = Game.settings.use_shaders

func set_enabled(enabled: bool) -> void:
	self.visible = enabled
