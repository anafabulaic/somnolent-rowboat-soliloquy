extends PanelContainer
class_name TrinketSelection

signal hover
signal equipped
signal unequipped

@export var icon: TextureRect
@export var title: Label
@export var desc: Label

@export var hover_sound: AudioStream
@export var select_sound: AudioStream

@export var equip_indicator: PanelContainer
var is_equipped: bool = false

var trinket_ref: TrinketReference

func set_icon(tex: Texture2D) -> void:
	icon.texture = tex
	
func set_title(text: String) -> void:
	title.text = text
	
func set_desc(text: String) -> void:
	desc.text = text

func set_equipped(_equipped: bool) -> void:
	equip_indicator.visible = _equipped
	is_equipped = _equipped
	
	if !is_equipped:
		self.theme_type_variation = "TrinketSelectionPanel"
	else:
		self.theme_type_variation = "TrinketSelectionPanelHover"

func _on_pressed() -> void:
	if !is_equipped:
		Game.trinkets.equip_trinket(trinket_ref)
		equipped.emit()
		self.theme_type_variation = "TrinketSelectionPanelHover"
		SignalBus.sound_play_on_ui.emit(select_sound, -5, 1.0)
	else:
		Game.trinkets.unequip_trinket(trinket_ref)
		unequipped.emit()
		self.theme_type_variation = "TrinketSelectionPanel"
		SignalBus.sound_play_on_ui.emit(select_sound, -5, 0.6)

func _on_hover() -> void:
	SignalBus.sound_play_on_ui.emit(hover_sound, -5, 1.0)
	hover.emit()
	self.theme_type_variation = "TrinketSelectionPanelHover"

func _on_unhover() -> void:
	if !is_equipped:
		self.theme_type_variation = "TrinketSelectionPanel"
