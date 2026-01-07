extends UISubMenu
class_name UISettingsSubMenu

@export var footnote: ExplainerFootnote

var is_footnote_hovering := false
var is_vol_text_hovering := false
var is_dragging := false

var sound_min: float = 0.0
var sound_max: float = 2.0

var vol_indicator_max: float = 200
var vol_indicator_min: float = 0

var in_summon: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%MasterVolumeSlider.min_value = sound_min
	%MasterVolumeSlider.max_value = sound_max
	
	%MusicVolumeSlider.min_value = sound_min
	%MusicVolumeSlider.max_value = sound_max
	
	%EffectsVolumeSlider.min_value = sound_min
	%EffectsVolumeSlider.max_value = sound_max
	
func summon() -> void:
	in_summon = true
	
	var master_vol := clampf(Game.settings.volume_master, sound_min, sound_max)
	var music_vol := clampf(Game.settings.volume_music, sound_min, sound_max)
	var effects_vol := clampf(Game.settings.volume_effects, sound_min, sound_max)
	
	%MasterVolumeSlider.value = master_vol
	%MusicVolumeSlider.value = music_vol
	%EffectsVolumeSlider.value = effects_vol
	
	%RenderScaleSlider.value = Game.settings.render_scale
	%VSyncOptions.selected = Game.settings.use_vsync
	%ShadersOptions.selected = Game.settings.use_shaders
	
	%MouseSensSlider.value = Game.settings.mouse_sensitivity
	%FovSlider.value = Game.settings.fov
	%HeadBobOptions.selected = Game.settings.use_headbobbing
	%ConsoleOptions.selected = Game.settings.enable_console
	%DebugOptions.selected = Game.settings.show_debug
	
	in_summon = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !self.visible:
		%Footnote.visible = false
		%VolumeHover.visible = false
		is_footnote_hovering = false
		return
		
	if is_footnote_hovering:
		%Footnote.position = get_global_mouse_position()
		
func _on_hover(text: String) -> void:
	%Footnote.visible = true
	%Footnote.set_custom_text("", text)
	
	is_footnote_hovering = true

func _on_hover_stop() -> void:
	%Footnote.visible = false
	
	is_footnote_hovering = false

func _on_tab_container_tab_hovered(tab: int) -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_hover_sound, 0.0, 1.0)

func _on_tab_container_tab_changed(tab: int) -> void:
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, 0.0, 1.0)	
	
#region Audio Settings
func _on_drag_started() -> void:
	is_dragging = true

func _on_drag_ended(value_changed: bool) -> void:
	is_dragging = true
	%VolumeHover.visible = false
	
func _on_master_volume_slider_value_changed(value: float) -> void:
	if in_summon:
		return
	
	if is_dragging: set_volume(value, true)	
	SignalBus.set_volume_master.emit(value)

func _on_music_volume_slider_value_changed(value: float) -> void:
	if in_summon:
		return
	
	if is_dragging: set_volume(value, true)
	SignalBus.set_volume_music.emit(value)

func _on_effects_volume_slider_value_changed(value: float) -> void:
	if in_summon:
		return
	
	if is_dragging: set_volume(value, true)
	SignalBus.set_volume_effects.emit(value)
	
func _on_master_volume_label_mouse_entered() -> void:
	_on_hover("Set the volume of all sounds.")

func _on_music_volume_label_mouse_entered() -> void:
	_on_hover("Set the volume of all music.")

func _on_effects_volume_label_mouse_entered() -> void:
	_on_hover("Set the volume of all in-game and UI effects")
	
func set_volume(value: float, use_vol: bool = false) -> void:
	var indicator_vol := remap(value, sound_min, sound_max, vol_indicator_min, vol_indicator_max)
	var pitch := remap(value, sound_min, sound_max, 0.5, 1.5)
	
	%VolumeHover.visible = true
	%VolumeHoverText.text = str(indicator_vol as int, "%")
	%VolumeHover.position = get_global_mouse_position()
	
	var vol := 0.0
	if use_vol:
		vol = linear_to_db(value)
	
	SignalBus.sound_play_on_ui.emit(System.sound.ui_hover_sound, vol, pitch)
#endregion

#region Graphics Settings
func _on_render_scale_label_mouse_entered() -> void:
	_on_hover("Sets the game's render scale.\
	 This game is rendering at such a low resolution that you probably don't need this, but go ahead if you want. \
	
	If you set it any higher than 100%, it makes the game look slightly smoother by internally rendering everything at x2 the resolution.")

func _on_v_sync_label_mouse_entered() -> void:
	_on_hover("Sets the V-Sync mode, which prevents your game from jittering at the cost of some input lag.")

func _on_shaders_label_mouse_entered() -> void:
	_on_hover("Enables screen effects.")

func _on_v_sync_options_item_selected(index: int) -> void:
	if in_summon:
		return
	
	match index:
		0: ## Disabled
			LimboConsole.BuiltinCommands.cmd_vsync(0)
			Game.settings.use_vsync = 0
		1: ## Enabled
			LimboConsole.BuiltinCommands.cmd_vsync(1)
			Game.settings.use_vsync = 1
		2: ## Adaptive
			LimboConsole.BuiltinCommands.cmd_vsync(2)
			Game.settings.use_vsync = 2
	
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, 0.0, 1.0)

func _on_shaders_options_item_selected(index: int) -> void:
	if in_summon:
		return
	
	match index:
		0: ## Disabled
			SignalBus.set_shaders_visible.emit(0)
			Game.settings.use_shaders = false
		1: ## Enabled
			SignalBus.set_shaders_visible.emit(1)
			Game.settings.use_shaders = true
			
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, 0.0, 1.0)

func _on_render_scale_slider_value_changed(value: float) -> void:
	if in_summon:
		return
	
	if !is_dragging:
		return
	
	var indicator_vol := remap(value, 0.1, 2.0, 10, 200)
	var pitch := remap(value, 0.1, 2.0, 0.5, 1.5)

	%VolumeHover.visible = true
	%VolumeHoverText.text = str(indicator_vol as int, "%")
	%VolumeHover.position = get_global_mouse_position()
	
	SignalBus.set_render_scale.emit(value)
	Game.settings.render_scale = value

	SignalBus.sound_play_on_ui.emit(System.sound.ui_hover_sound, 0.0, pitch)
#endregion

#region General Settings
func _on_mouse_sens_label_mouse_entered() -> void:
	_on_hover("Sets your camera turning speed. Compatible with Source Engine values.")

func _on_fov_label_mouse_entered() -> void:
	_on_hover("Sets your camera's field of view.")

func _on_head_bob_label_mouse_entered() -> void:
	_on_hover("Enables the bobbing effect when you move.")

func _on_console_label_mouse_entered() -> void:
	_on_hover("Enables the developer console, accessible with the ~ key.")

func _on_debug_label_mouse_entered() -> void:
	_on_hover("Enables debug mode.")

func _on_mouse_sens_slider_value_changed(value: float) -> void:
	if in_summon:
		return
	
	if !is_dragging:
		return

	var pitch := remap(value, 0.1, 6.0, 0.5, 1.5)

	%VolumeHover.visible = true
	%VolumeHoverText.text = str(value)
	%VolumeHover.position = get_global_mouse_position()
	
	SignalBus.set_mouse_sens.emit(value)
	SignalBus.sound_play_on_ui.emit(System.sound.ui_hover_sound, 0.0, pitch)

func _on_fov_slider_value_changed(value: float) -> void:
	if in_summon:
		return
	
	if !is_dragging:
		return

	var pitch := remap(value, 30.0, 110.0, 0.5, 1.5)

	%VolumeHover.visible = true
	%VolumeHoverText.text = str(value as int)
	%VolumeHover.position = get_global_mouse_position()
	
	SignalBus.set_fov.emit(value)
	SignalBus.sound_play_on_ui.emit(System.sound.ui_hover_sound, 0.0, pitch)

func _on_head_bob_options_item_selected(index: int) -> void:
	if in_summon:
		return
	
	match index:
		0: ## Disabled
			SignalBus.set_headbob_enabled.emit(0)
		1: ## Enabled
			SignalBus.set_headbob_enabled.emit(1)
			
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, 0.0, 1.0)

func _on_console_options_item_selected(index: int) -> void:
	if in_summon:
		return
	
	match index:
		0: ## Disabled
			SignalBus.set_console_enabled.emit(0)
			Game.settings.enable_console = false
		1: ## Enabled
			SignalBus.set_console_enabled.emit(1)
			Game.settings.enable_console = true
			
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, 0.0, 1.0)

func _on_debug_options_item_selected(index: int) -> void:
	if in_summon:
		return
	
	match index:
		0: ## Disabled
			SignalBus.set_debug_enabled.emit(0)
		1: ## Enabled
			SignalBus.set_debug_enabled.emit(1)
			
	SignalBus.sound_play_on_ui.emit(System.sound.ui_select_sound, 0.0, 1.0)
#endregion
