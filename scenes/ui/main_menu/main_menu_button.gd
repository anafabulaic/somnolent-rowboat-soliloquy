extends Button
class_name UIMainMenuButton

@export var wanted_submenu: UIMenuManager.SubMenu
@export var set_up_sounds: bool = false

func _enter_tree() -> void:
	self.pressed.connect(request_submenu)
	
	self.mouse_entered.connect(_play_hover_sound)
	if wanted_submenu == UIMenuManager.SubMenu.None:
		self.pressed.connect(_play_click_sound_back)
	else:
		self.pressed.connect(_play_click_sound)
		
func request_submenu() -> void:
	SignalBus.set_submenu.emit(wanted_submenu)

func _play_hover_sound() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_hover_sound, 0.0, 1.0)

func _play_click_sound_back() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, 0.0, 0.8)

func _play_click_sound() -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, 0.0, 1.0)
	
