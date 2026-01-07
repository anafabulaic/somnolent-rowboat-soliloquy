extends PanelContainer
class_name UIOptionsMenuTab

signal wants_select(tab: UIOptionsMenuTab)

@export var button: Button
@export var inner2: Control
@export var panel: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	wants_select.emit(self)

func hide_panel() -> void:
	panel.visible = false
	
func show_panel() -> void:
	panel.visible = true

func set_selected() -> void:
	inner2.theme_type_variation = "OptionsMenuTabBGSelected"
	show_panel()
	
func set_unselected() -> void:
	inner2.theme_type_variation = "OptionsMenuTabBGUnselected"
	hide_panel()
