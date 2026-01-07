extends Node
class_name SoundLibrary

@export_group("UI")
@export var ui_hover_sound: AudioStream # Default UI hover sound
@export var ui_select_sound: AudioStream # Default UI click sound
@export var ui_tooltip_sound: AudioStream # Default tooltip pop sound.
@export var ui_trinket_get: AudioStream # Default trinket obtain sound
@export var ui_ding: AudioStream

@export_group("Effects")
@export var teleport_sound: AudioStream
