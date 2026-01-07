extends Node

@export_group("Libraries")
@export var sound: SoundLibrary

@export_group("Defaults")
@export var default_soundmat: SoundMatResource
@export var default_settings: GameSettings
@export var player_scene: PackedScene = preload("uid://bec55rns5p0a8")

@export_group("Resources")
enum Footsteps {
	DEFAULT,
	WATER,
	LADDER
}

@export var footstep_library: Dictionary[Footsteps, FootstepMatResource] = {
	Footsteps.DEFAULT: preload("uid://dwrlck5egrnbq"),
	Footsteps.WATER: preload("uid://dt63u0a74ym3j"),
	Footsteps.LADDER: preload("uid://dr3la6gklifuf")
}

#region Effects
@export_group("Effects")
enum TransitionType {
	zoom,
	strip,
	fade,
}

@export var effect_water: PackedScene = preload("uid://c3kk1iv5q7ia6")
#endregion

@export_group("Libraries")

@export var map_library: Dictionary[String, String] = {}
@export var trinket_library: Dictionary[String, String] = {}

func get_maps(path: String) -> void:
	var new_dict: Dictionary = {}
	new_dict = get_all_files(path, "tscn", "PackedScene", new_dict)
	
	if new_dict.is_empty():
		LimboConsole.error("Map list is empty! This is really bad!")
		return
	
	var map_count: int = 0
	var start_time: int = Time.get_ticks_msec()
	
	for entry: String in new_dict:
		System.map_library[entry.trim_suffix(".tscn")] = new_dict[entry]
		map_count += 1
		#LimboConsole.info(str("Found map - ", entry.trim_suffix(".tscn")))
	
	var end_time: int = Time.get_ticks_msec() - start_time
	
	LimboConsole.info(str("Found ", map_count, " maps in ", end_time, " ms"))

func get_trinkets(path: String) -> void:
	var new_dict: Dictionary = {}
	new_dict = get_all_files(path, "tres", "TrinketReference", new_dict)
	
	if new_dict.is_empty():
		LimboConsole.error("Trinket list is empty! This is really bad!")
		return
		
	var trinket_count: int = 0
	var start_time: int = Time.get_ticks_msec()
	
	for entry: String in new_dict:
		#LimboConsole.info(str("Reading: ", entry))
		var load_trinket := load(new_dict[entry])
		if load_trinket is TrinketReference:
			if load_trinket.validate():
				System.trinket_library[entry.trim_suffix(".tres")] = new_dict[entry]
				trinket_count += 1
			
	if System.trinket_library.is_empty():
		LimboConsole.error("Trinket list is empty! This is really bad!")
		return
	
	var end_time: int = Time.get_ticks_msec() - start_time
	
	LimboConsole.info(str("Found ", trinket_count, " trinkets in ", end_time, " ms"))

func get_all_files(path: String, file_ext: String, type_hint: String, files: Dictionary = {}) -> Dictionary:
	var dir: DirAccess = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()

		var file_name: String = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir() + "/" + file_name, file_ext, type_hint, files)
			else:
				#LimboConsole.info(str("Found file named: ", file_name))
				if file_name.get_extension() == "remap":
					file_name = file_name.trim_suffix(".remap")
				elif file_name.get_extension() == "import":
					file_name = file_name.trim_suffix(".import")
				
				if file_ext and file_name.get_extension() and file_name.trim_suffix(".remap").get_extension() and file_name.trim_suffix(".import").get_extension() != file_ext:
					file_name = dir.get_next()
					continue
				
				var file_path := dir.get_current_dir() + "/" + file_name
				var resource_load := ResourceLoader.exists(file_path)
				
				if resource_load:
					files[file_name] = file_path
					#LimboConsole.info(str("Found resource named: ", file_name, " with UID: ", ResourceUID.ensure_path(file_path)))
				#files[file_name] = file_path

			file_name = dir.get_next()
	else:
		LimboConsole.error(str("An error occurred when trying to access %s." % path))
		print("An error occurred when trying to access %s." % path)

	return files
