extends Control
class_name UIManager

@export var background: ColorRect
@export var menu: UIMenuManager

var paused: bool = false

func _ready() -> void:
	pass

func pause() -> void:
	paused = true
	
	menu.modulate.a = 0.0
	menu.visible = true
	background.visible = true
	
	var tween := self.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(menu, "modulate", Color.WHITE, 0.2)
	
	menu.clear_submenu()
	menu.on_show()
	
	if Game.current_scene:
		menu.set_mode(UIMenuManager.MenuMode.PauseMenu)
	else:
		menu.set_mode(UIMenuManager.MenuMode.MainMenu)
		
func unpause() -> void:
	paused = false
	
	menu.visible = false
	background.visible = false
