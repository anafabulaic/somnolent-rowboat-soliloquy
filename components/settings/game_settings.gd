extends Resource
class_name GameSettings

#@export_group("General")
#@export var lock_cursor_on_start: bool = true

@export_group("Debug")
@export var use_alternate_physics: bool = false ## Doesn't do anything
@export var enable_console: bool = true
@export var show_debug: bool = false

@export_group("User Settings")
@export_range(0.0,2.0) var volume_master: float = 1.0
@export_range(0.0,2.0) var volume_music: float = 1.5
@export_range(0.0,2.0) var volume_effects: float = 1.0

@export_range(0.1, 2.0) var render_scale: float = 1.0
@export_enum("Disabled", "Enabled", "Adaptive") var use_vsync: int = 1
@export_enum("Disabled", "Enabled") var use_shaders: int = 1
		
@export var fov: float = 90.0
@export var mouse_sensitivity: float = 3.0

@export var use_headbobbing: bool = true

@export_group("Interaction")
@export var max_prop_size: float = 5.0
@export var max_prop_weight: float = 80.0

@export_group("Camera/UI")
@export var headbob_amount: float = 0.03
@export var headbob_frequency: float = 2.4

@export var crosshair_radius: float = 2.0

@export_group("Movement Settings")
@export var jump_buffer: float = 0.2
@export var coyote_time: float = 0.2 ## Doesn't do anything right now

func save() -> Dictionary:
	var save_dict: Dictionary = {
		"volume_master": volume_master,
		"volume_music": volume_music,
		"volume_effects": volume_effects,
		"render_scale": render_scale,
		"use_vsync": use_vsync,
		"use_shaders": use_shaders,
		"fov": fov,
		"mouse_sensitivity": mouse_sensitivity,
		"use_headbobbing": use_headbobbing
	}
	
	return save_dict

func load(save_dict: Dictionary) -> void:
	for i: String in save_dict:
		if i in self:
			self.set(i, save_dict[i])
