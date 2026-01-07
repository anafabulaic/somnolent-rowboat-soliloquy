extends Node

# System

signal on_level_changed
signal on_level_ready

signal paused
signal unpaused

signal load_game(slot: int)
signal save_game
signal on_save_game

# Settings
signal set_volume_master(vol: float)
signal set_volume_music(vol: float)
signal set_volume_effects(vol: float)

signal set_render_scale(scale: float)
signal set_shaders_visible(enabled: bool)

signal set_mouse_sens(sens: float)
signal set_fov(fov: float)
signal set_headbob_enabled(enabled: bool)
signal set_console_enabled(enabled: bool)
signal set_debug_enabled(enabled: bool)

# Effects
signal spawn_particles(effect: PackedScene, pos: Vector3)
signal transition_captured_screen
signal transition_begin_done
signal transition_end_done

# Interaction

signal do_interact_error
signal do_interact_lesser_error
signal do_interact_bounce

# UI

signal ui_do_tooltip(text: String, expiration_time: float, sound: AudioStream)
signal ui_cancel_tooltip(text: String)
signal ui_clear_tooltips
signal ui_do_transition(transition: TransitionEffectResource, duration: float, is_level_change: bool)

signal set_submenu(submenu: UIMenuManager.SubMenu)

# Player Data

signal on_premove(stats: PlayerStatSheet, delta: float)
signal on_postmove(stats: PlayerStatSheet, delta: float)

# Items

signal on_trinket_add(trinket: TrinketReference)
signal on_trinket_remove(trinket: TrinketReference)
signal on_trinket_equipped(trinket: TrinketReference)
signal on_trinket_unequipped(trinket: TrinketReference)

signal on_trinket_use(trinket: TrinketReference)

signal clear_trinkets

# Audio

signal set_next_music(next: MusicResource)
signal stop_music

signal sound_play_3D_simple(sound: AudioStream, pos: Vector3)
signal sound_play_3D(sound: AudioStream, pos: Vector3, vol: float, pitch: float, bus: String)
signal sound_play_on_ui(sound: AudioStream, vol: float, pitch: float)
signal sound_play_2D(sound: AudioStream, vol: float, pitch: float, bus: String)
