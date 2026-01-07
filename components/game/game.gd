extends Node3D

@export var settings: GameSettings = preload("res://components/settings/default_settings.tres")

@export var current_scene: MapScene
@export var player: Player
@export var current_save: SaveGame

@export_group("Dependencies")
@export var scene_holder: Node3D
@export var ui: UIManager
@export var effects: EffectsManager
@export var trinkets: TrinketManager
@export var audio: AudioManager

@export_group("Debug")
@export var load_default_map: bool = false
@export var cheats: bool = false
@export_file("*.tscn") var wake_map: String = "res://maps/"
@export_file("*.tscn") var default_map: String = "res://maps/"
@export var default_map_name: String
@export var menu_music: MusicResource

var mouse_in_window: bool = false
var focused: bool = false

var can_open_console: bool = true
var can_pause: bool = true
var is_paused: bool = false

var is_awake: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if settings.lock_cursor_on_start and focused and mouse_in_window:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	System.get_maps("res://maps/")
	System.get_trinkets("res://trinkets/")
	LimboConsole._greet()
	
	#LimboConsole.info(str("Our default map path is ", ResourceUID.ensure_path(default_map)))
	
	LimboConsole.toggled.connect(get_console_pause)
	
	load_settings()

	_init_debug()
	_init_settings()
	_init_signals()
	_init_console_commands()

	load_save()

	if default_map_name and load_default_map:
		%Cutscene.destroy()
		load_player()
		load_scene(System.map_library[default_map_name])
		pause()
	elif load_default_map:
		%Cutscene.destroy()
		#unpause()
		load_player()
		load_scene(default_map)
		pause()
	else:
		await %Cutscene.done
		SignalBus.set_next_music.emit(menu_music)
		pause()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			focused = true
			try_unpause()
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			focused = false
			try_pause()
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_in_window = true
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_in_window = false
		NOTIFICATION_WM_CLOSE_REQUEST:
			print("Saved!")
			save_settings()
		NOTIFICATION_APPLICATION_PAUSED:
			print("Saved!")
			save_settings()
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and can_pause:
		toggle_pause()
		return
		
#region Init
func _init_settings() -> void:
	if not settings:
		settings = System.default_settings
		
	_console_set_volume_master(settings.volume_master)
	_console_set_volume_music(settings.volume_music)
	_console_set_volume_effects(settings.volume_effects)
	
	_console_set_render_scale(settings.render_scale)
	_console_set_shaders_enabled(settings.use_shaders)
	
	_console_set_mouse_sens(settings.mouse_sensitivity)
	_console_set_fov(settings.fov)
	_console_set_headbob(settings.use_headbobbing)
	_console_toggle_debug(settings.show_debug)

func _init_console_commands() -> void:
	LimboConsole.register_command(_console_set_cheats, "sv_cheats", "Toggle cheats.")
	
	LimboConsole.register_command(_console_toggle_debug, "cl_showdebug", "Toggle debug stats.")
	
	LimboConsole.register_command(_console_load_scene, "map", "Load a map. Cheat command.")
	LimboConsole.add_argument_autocomplete_source("map", 0, func() -> Array: return System.map_library.keys())
	
	LimboConsole.register_command(_console_add_trinket, "add_trinket", "Gives you a trinket. Cheat command.")
	LimboConsole.add_argument_autocomplete_source("add_trinket", 0, func() -> Array: return System.trinket_library.keys())
	
	LimboConsole.register_command(func() -> void: SignalBus.ui_clear_tooltips.emit(), "clear_tooltips", "Clears all tooltips")
	
	LimboConsole.register_command(_console_set_volume_master, "set_volume_master", "Sets master volume. Range is 0.0 to 2.0")
	LimboConsole.register_command(_console_set_volume_music, "set_volume_music", "Sets music volume. Range is 0.0 to 2.0")
	LimboConsole.register_command(_console_set_volume_effects, "set_volume_effects", "Sets effect volume. Range is 0.0 to 2.0")

	LimboConsole.register_command(_console_set_render_scale, "render_scale", "Sets the 3D rendering scale. Range is 0.1 to 2.0")
	LimboConsole.register_command(_console_set_shaders_enabled, "cl_screenshaders", "Enables screen shader effects." )
	
	LimboConsole.register_command(_console_set_mouse_sens, "sensitivity", "Changes your mouse sensitivity. Range is 0.1 to 6.0")
	LimboConsole.register_command(_console_set_fov, "fov", "Sets your camera's field of view. Range is 30.0 to 110.0")
	LimboConsole.register_command(_console_set_headbob, "cl_headbob", "Enables head-bobbing while moving.")
	
func _init_signals() -> void:
	SignalBus.set_volume_master.connect(_console_set_volume_master)
	SignalBus.set_volume_music.connect(_console_set_volume_music)
	SignalBus.set_volume_effects.connect(_console_set_volume_effects)
	
	SignalBus.set_render_scale.connect(_console_set_render_scale)
	
	SignalBus.set_mouse_sens.connect(_console_set_mouse_sens)
	SignalBus.set_fov.connect(_console_set_fov)
	SignalBus.set_headbob_enabled.connect(_console_set_headbob)
	SignalBus.set_console_enabled.connect(set_console_enabled)
	SignalBus.set_debug_enabled.connect(_console_toggle_debug)
	
	SignalBus.save_game.connect(save_game)

func _init_debug() -> void:
	var debugconfig: DebugDraw2DConfig = DebugDraw2DConfig.new()
	debugconfig.text_custom_font = preload("res://fonts/Caladea-Bold.ttf")
	DebugDraw2D.config = debugconfig
#endregion

func get_awake() -> bool:
	return is_awake and current_scene

func start_new_game(use_fresh_save: bool) -> void:
	if use_fresh_save or !current_save:
		current_save = SaveGame.new()
		create_p_values(current_save)
	
	Game.load_player()
	Game.load_scene(Game.wake_map)
	ui.menu.set_mode(UIMenuManager.MenuMode.PauseMenu)
	Game.unpause()
	
func unload_game() -> void:
	unload_player()
	trinkets.clear_trinkets()
	unload_scene()
	ui.menu.set_mode(UIMenuManager.MenuMode.MainMenu)
	SignalBus.set_next_music.emit(menu_music)
	set_music_low_pass(false)

#region Saving and Loading
func save_settings() -> void:
	var settings_file := FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	
	if settings:
		settings_file.store_line(JSON.stringify("settings"))
		var settings_dict := settings.save()
		settings_file.store_line(JSON.stringify(settings_dict))

func save_game() -> void:
	save_settings()
	
	var save_file := FileAccess.open("user://savegame.save", FileAccess.WRITE)

	if current_save:
		save_file.store_line(JSON.stringify("save"))
		var save_dict := current_save.save()
		save_file.store_line(JSON.stringify(save_dict))
		
		save_file.store_line(JSON.stringify("trinkets"))
		var trinkets_array: Array = trinkets.get_owned_trinket_names()
		save_file.store_line(JSON.stringify(trinkets_array))
		
		save_file.store_line(JSON.stringify("visited_worlds"))
		var worlds_array: Array = current_save.visited_worlds
		save_file.store_line(JSON.stringify(worlds_array))
		
		SignalBus.on_save_game.emit()

func load_settings() -> void:
	if not FileAccess.file_exists("user://settings.cfg"):
		return
		
	var settings_file := FileAccess.open("user://settings.cfg", FileAccess.READ)
	
	while settings_file.get_position() < settings_file.get_length():
		var json_string := settings_file.get_line()
		var json := JSON.new()
		
		var parse_result := json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		var node_data: Variant = json.data
		
		if node_data is Dictionary:
			settings = GameSettings.new()
			settings.load(node_data)

func load_save() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		return

	var save_file := FileAccess.open("user://savegame.save", FileAccess.READ)
	var load_mode: String = ""
	var save_file_blank := SaveGame.new()
	
	while save_file.get_position() < save_file.get_length():
		var json_string := save_file.get_line()
		var json := JSON.new()
		
		var parse_result := json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		var node_data: Variant = json.data
		
		match node_data:
			"save", "trinkets", "visited_worlds":
				load_mode = node_data
				continue
		
		match load_mode:
			"save":
				save_file_blank.load(node_data)
				load_mode = ""
				continue
			"trinkets":
				save_file_blank.load_trinkets(node_data)
				load_mode = ""
				continue
			"visited_worlds":
				save_file_blank.load_worlds(node_data)
				load_mode = ""
				continue
				
	current_save = save_file_blank
	
func create_p_values(save: SaveGame) -> void:
	save.p_unique = OS.get_unique_id().hash()
#endregion

#region Scene Loading
func load_scene(scene: String, spawnpoint: String = "") -> void:
	var scene_path: String = ResourceUID.ensure_path(scene)
	
	if !System.map_library.values().has(scene_path):
		var missing_scene_str := str("Couldn't find a scene at specified path ", scene)
		LimboConsole.error(missing_scene_str)
		printerr(missing_scene_str)
	
	var loaded_scene: PackedScene = load(scene_path)
	
	if !player:
		load_player()
	
	if loaded_scene:
		if current_scene:
			SignalBus.stop_music.emit()
			
			current_scene.queue_free()
	
			for nodes in get_tree().get_nodes_in_group("Spawnpoints"):
				nodes.remove_from_group("Spawnpoints")
		
		current_scene = loaded_scene.instantiate()
		current_scene.process_mode = Node.PROCESS_MODE_PAUSABLE

		LimboConsole.info(str("Loaded ", System.map_library.find_key(scene_path)))
		
		scene_holder.add_child(current_scene)
		
		var map_name := current_scene.map_name
		
		if map_name == "srs_site433":
			is_awake = true
			if trinkets.current_trinket:
				trinkets.unequip_trinket(trinkets.current_trinket)
		else:
			is_awake = false
			
		if current_save:
			if System.map_library.has(map_name) and !current_save.visited_worlds.has(map_name) and !current_scene.is_sub_world:
				print("Added ", map_name, " to record!")
				current_save.visited_worlds.append(map_name)
		
		Game.player.lock(true)
		
		if !current_scene.spawnpoints.is_empty():
			var wanted_spawn: MapSpawnPoint = current_scene.spawnpoints[0]
			var found_desired_spawn: bool = false
			
			if !spawnpoint.is_empty():
				for sp in current_scene.spawnpoints:
					if sp.spawn_point_name == spawnpoint:
						wanted_spawn = sp
						found_desired_spawn = true
						break
			
				if !found_desired_spawn:			
					var desired_spawn_warn := str("Couldn't find desired spawn called ", spawnpoint, " for map ", current_scene.map_name,\
					 ". Falling back to index 0 of the list.")
					LimboConsole.warn(desired_spawn_warn)
					print(desired_spawn_warn)
			#else:
				#var spawnpoint_empty_str := str("Map was loaded with a blank spawnpoint param, so we'll just go with the first one we found.")
				#LimboConsole.warn(spawnpoint_empty_str)
				#print(spawnpoint_empty_str)

			reset_player()
			set_player_transform(wanted_spawn.global_transform)
		else:
			var empty_str := str("Spawnpoint list for ", current_scene.map_name, " was empty, falling back to world origin.")
			LimboConsole.error(empty_str)
			printerr(empty_str)
			var empty_trans: Transform3D = Transform3D(Basis.IDENTITY, Vector3.ZERO)
			
			reset_player()
			set_player_transform(empty_trans)
		
		# we need to defer this for later because if you load the level too fast, nodes waiting for the level load signal will miss it
		call_deferred("emit_load_signals")
	else:
		var err_string := str("Couldn't load scene named ", System.map_library.find_key(scene), " because path ", scene_path, " is invalid!")
		LimboConsole.error(err_string)
		printerr(err_string)

func emit_load_signals() -> void:
	SignalBus.on_level_changed.emit()
	SignalBus.ui_clear_tooltips.emit()
	
	if !player:
		return
	
	player.unlock(true)
	
	## HACK: we wait two physics frames after loading so we don't make a landing sound upon entering the scene
	player.enable_steps()

func load_player() -> void:
	if !System.player_scene:
		push_error("Couldn't find player scene!")
		
	player = System.player_scene.instantiate()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE

	scene_holder.add_child(player)

func unload_player() -> void:
	if !player:
		return

	player.queue_free()
	player = null
	
func unload_scene() -> void:
	if !current_scene:
		return
	
	SignalBus.ui_clear_tooltips.emit()
	SignalBus.stop_music.emit()
	
	current_scene.queue_free()
	current_scene = null
# TODO: replace param with an enum or something later so it's less fragile
func set_player_state(state: String) -> void:
	if player:
		player.set_state(state)

func set_player_transform(trans: Transform3D) -> void:
	if player:	
		player.set_player_transform(trans)

## for teleporting or changing levels
func reset_player() -> void:
	if player:
		player.velocity = Vector3.ZERO
		player.stats.velocity = Vector3.ZERO
		player.set_state("PlayerFallingState")
#endregion

#region Pausing
func toggle_pause() -> void:
	if is_paused and current_scene:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		SignalBus.sound_play_on_ui.emit(System.sound.ui_tooltip_sound, -5.0, 0.5)
		unpause()
	elif !is_paused:
		SignalBus.sound_play_on_ui.emit(System.sound.ui_tooltip_sound, -5.0, 0.4)
		pause()

func get_console_pause(is_shown: bool) -> void:
	if is_shown:
		pause()
	else:
		unpause()

func try_pause() -> void:
	if !is_paused and can_pause:
		pause()
		
func try_unpause() -> void:
	if current_scene and !is_paused and can_pause and mouse_in_window:
		unpause()
		
func pause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	is_paused = true
	
	get_tree().paused = true
	ui.pause()
	
	if Game.current_scene:
		set_music_low_pass(true)
	else:
		set_music_low_pass(false)
	
	SignalBus.paused.emit()
	
func unpause() -> void:
	if !current_scene:
		return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	is_paused = false
	
	get_tree().paused = false
	LimboConsole.close_console()
	ui.unpause()
	
	set_music_low_pass(false)
	
	SignalBus.unpaused.emit()
	
func set_music_low_pass(do_lp: bool) -> void:
	var bus_index := AudioServer.get_bus_index("Music")
	var music_lowpass := AudioServer.get_bus_effect(bus_index, 0)
	
	if !music_lowpass:
		return
	
	if do_lp:
		AudioServer.set_bus_effect_enabled(bus_index, 0, true)
	else:
		AudioServer.set_bus_effect_enabled(bus_index, 0, false)
	
func awaken() -> void:
	if !current_scene or !player:
		return
		
	SignalBus.sound_play_on_ui.emit(System.sound.teleport_sound, 0.0, 1.0)
	
	var fade_effect := preload("res://scenes/ui/transition_effect/fade_transition_effect.tres")
	
	SignalBus.ui_do_transition.emit(fade_effect, 2.0, true)
	SignalBus.stop_music.emit()
	
	await SignalBus.transition_captured_screen
	
	Game.load_scene(wake_map, "default")
	
#endregion

#region Console Commands
func set_console_enabled(enabled: bool) -> void:
	can_open_console = enabled

func _console_set_cheats(toggle: bool) -> void:
	LimboConsole.info(str("Set cheats to ", toggle))
	cheats = toggle

func _console_toggle_debug(toggle: bool) -> void:	
	DebugDraw2D.clear_all()
	Game.settings.show_debug = toggle
	
func _console_load_scene(scene_name: String) -> void:
	if !cheats:
		LimboConsole.info("Cheats are disabled! Enable them using the sv_cheats command.")
		return
	
	if System.map_library.get(scene_name) == null:
		LimboConsole.error("Invalid scene name.")
		return
		
	if !current_scene or !player:
		LimboConsole.error("You need to be in a game to use this")
		return

	load_scene(System.map_library[scene_name])
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	unpause()
	
func _console_add_trinket(trinket_name: String) -> void:
	if !cheats:
		LimboConsole.info("Cheats are disabled! Enable them using the sv_cheats command.")
		return
		
	if System.trinket_library.get(trinket_name) == null:
		LimboConsole.error("Invalid scene name.")
		return
		
	if !current_scene or !player:
		LimboConsole.error("You need to be in a game to use this")
		return
	
	LimboConsole.info(str("Added trinket: ", trinket_name))
	trinkets.add_trinket_by_name(trinket_name)
	
func _console_set_volume_master(volume: float) -> void:
	volume = clampf(volume, 0.0, 2.0)
	
	Game.settings.volume_master = volume
	
	volume = linear_to_db(volume)
	var index := AudioServer.get_bus_index("Master")

	AudioServer.set_bus_volume_db(index, volume)

func _console_set_volume_music(volume: float) -> void:
	volume = clampf(volume, 0.0, 2.0)
	
	Game.settings.volume_music = volume
	
	volume = linear_to_db(volume)
	var index := AudioServer.get_bus_index("Music")

	AudioServer.set_bus_volume_db(index, volume)
	
func _console_set_volume_effects(volume: float) -> void:
	volume = clampf(volume, 0.0, 2.0)
	
	Game.settings.volume_effects = volume
	
	volume = linear_to_db(volume)
	
	var set_vol := func(bus: String) -> void:
		var index := AudioServer.get_bus_index(bus)
		AudioServer.set_bus_volume_db(index, volume)
	
	set_vol.call("Footsteps")
	set_vol.call("Foley")
	set_vol.call("UI")
	set_vol.call("UI_NoReverb")
	
func _console_set_render_scale(render_scale: float) -> void:
	render_scale = clampf(render_scale, 0.1, 2.0)
	
	get_viewport().scaling_3d_scale = render_scale
	LimboConsole.info(str("Set render scale to ", render_scale))

func _console_set_shaders_enabled(enabled: bool) -> void:
	SignalBus.set_shaders_visible.emit(enabled)
	if enabled:
		LimboConsole.info("Enabled screen shaders.")
	else:
		LimboConsole.info("Disabled screen shaders.")
		
func _console_set_mouse_sens(sens: float) -> void:
	sens = clampf(sens, 0.1, 6.0)
	
	Game.settings.mouse_sensitivity = sens
	LimboConsole.info(str("Set mouse sensitivity to ", sens))
	
func _console_set_fov(fov: float) -> void:
	fov = clampf(fov, 30.0, 110.0)
	
	Game.settings.fov = fov
	LimboConsole.info(str("Set field of view to ", fov))
	
func _console_set_headbob(enabled: bool) -> void:
	Game.settings.use_headbobbing = enabled
	
	if enabled:
		LimboConsole.info("Enabled headbobbing.")
	else:
		LimboConsole.info("Disabled headbobbing.")
#endregion
