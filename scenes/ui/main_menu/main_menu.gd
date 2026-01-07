extends Control
class_name UIMenuManager

@export var manager: UIManager

enum MenuMode {
	None,
	MainMenu,
	PauseMenu
}

enum SubMenu {
	None,
	Trinkets,
	WakeUp,
	Help,
	Settings,
	Start,
	Load,
	QuitToMenu,
	QuitGame
}

var current_menu: MenuMode = MenuMode.MainMenu 
var current_menu_control: Control

var current_submenu: SubMenu
var current_submenu_control: Control

var current_focus: Control

func _ready() -> void:
	SignalBus.set_submenu.connect(set_submenu)
	pass
	#for child in find_children("*", "Button"):
		#if child is UIMainMenuButton:
			#var button: UIMainMenuButton = child
			#button.mouse_entered.connect(Game.audio._play_hover_sound)
			#if child.wanted_submenu == SubMenu.None:
				#button.pressed.connect(Game.audio._play_click_sound_back)
			#else:
				#button.pressed.connect(Game.audio._play_click_sound)
			#button.call_submenu.connect(set_submenu)

# All of this UI code is kind of shit.
# TODO: come up with complicated overengineered thing for this later

func on_show() -> void:
	if Game.get_awake():
		%TRINKETS.visible = false
		%TERMINATE.visible = false
		%WakeSeparator.visible = false
	else:
		%TRINKETS.visible = true
		%TERMINATE.visible = true
		%WakeSeparator.visible = true
		
	if Game.current_save and Game.current_save.last_save_unix_time > 0:
		%LOAD.visible = true
		%LoadSeparator.visible = true
	else:
		%LOAD.visible = false
		%LoadSeparator.visible = false

func set_submenu(menu: SubMenu) -> void:
	match menu:
		SubMenu.None:
			clear_submenu()
		SubMenu.Trinkets:
			_set_submenu(%TrinketsSubMenu, SubMenu.Trinkets)
		SubMenu.WakeUp:
			_set_submenu(%WakeSubMenu, SubMenu.WakeUp)
		SubMenu.Help:
			_set_submenu(%HelpSubMenu, SubMenu.Help)
		SubMenu.Settings:
			_set_submenu(%SettingsSubMenu, SubMenu.Settings)
		SubMenu.Start:
			_set_submenu(%StartGameSubMenu, SubMenu.Start)
		SubMenu.Load:
			_set_submenu(%LoadGameSubMenu, SubMenu.Load)
		SubMenu.QuitGame:
			_set_submenu(%QuitGameSubMenu, SubMenu.QuitGame)
		SubMenu.QuitToMenu:
			_set_submenu(%QuitToMenuSubMenu, SubMenu.QuitToMenu)

func clear_submenu() -> void:
	%Menus.visible = true
	
	current_submenu = SubMenu.None
	
	if current_submenu_control:
		current_submenu_control.visible = false
		
	if current_menu_control:
		current_focus = current_menu_control

func _set_submenu(menu: UISubMenu, menu_enum: SubMenu) -> void:
	if !can_use_submenu(menu):
		return
		
	current_submenu = menu_enum
	
	for child in get_children():
		if child is UISubMenu:
			child.visible = false
			child.modulate.a = 1.0
	
	%Menus.visible = false
	
	current_submenu_control = menu
	menu.summon()
	menu.visible = true
	menu.modulate.a = 0.0
	
	var tween := self.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(menu, "modulate", Color.WHITE, 0.2)
	
	current_focus = current_submenu_control

func can_use_submenu(submenu: UISubMenu) -> bool:
	if submenu.required_mode == MenuMode.None:
		return true
	
	return current_menu == submenu.required_mode

func set_mode(mode: MenuMode) -> void:
	match mode:
		MenuMode.MainMenu:
			current_menu = MenuMode.MainMenu
			current_menu_control = %MainMenuContainer
			current_focus = current_menu_control
			
			%PauseMenuContainer.visible = false
			%MainMenuContainer.visible = true
		MenuMode.PauseMenu:
			current_menu = MenuMode.PauseMenu
			current_menu_control = %PauseMenuContainer
			current_focus = current_menu_control
			
			%PauseMenuContainer.visible = true
			%MainMenuContainer.visible = false
