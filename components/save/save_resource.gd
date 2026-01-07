extends Resource
class_name SaveGame

@export var save_slot: int = 0
@export var triggered_first_time_events: bool = false
@export var last_save_unix_time: float = 0

@export var trinkets: Array[String]
@export var visited_worlds: Array[String]

@export_group("Personal")
@export var p_unique: int
@export var p_love: int = 100

@export_group("Stats")
@export var seconds_played: float = 0.0
@export var steps_walked: int = 0
@export var days: int = 0
@export var kills: int = 0

func save() -> Dictionary:
	last_save_unix_time = Time.get_unix_time_from_system()
	
	var save_dict: Dictionary = {
		"save_slot": save_slot,
		"triggered_first_time_events": triggered_first_time_events,
		"last_save_unix_time": Time.get_unix_time_from_system(),
		"p_unique": p_unique,
		"p_love": p_love,
		"seconds_played": seconds_played,
		"steps_walked": steps_walked,
		"days": days,
		"kills": kills
	}
	
	return save_dict

func load(save_dict: Dictionary) -> void:
	for i: String in save_dict:
		if i in self:
			self.set(i, save_dict[i])

func load_trinkets(trinket_array: Array) -> void:
	if trinket_array.is_empty():
		return
	
	var trinket_array_blank: Array[String] = []
	
	for i: String in trinket_array:
		if System.trinket_library.has(i):
			trinket_array_blank.append(i)
			
	if trinket_array_blank.is_empty():
		LimboConsole.info("Loaded a trinket array but it was empty.")
	else:
		trinkets = trinket_array_blank.duplicate()
		
func load_worlds(world_array: Array) -> void:
	if world_array.is_empty():
		return

	var world_array_blank: Array[String] = []

	for i: String in world_array:
		if System.map_library.has(i):
			world_array_blank.append(i)

	if world_array_blank.is_empty():
		LimboConsole.info("Loaded a world array but it was empty.")
	else:
		visited_worlds = world_array_blank.duplicate()

func format_time(total_seconds: float) -> String:
	var _days: int = floor(total_seconds / 86400.0)
	var remaining_seconds: float = total_seconds - (_days * 86400.0)

	var hours: int = floor(remaining_seconds / 3600.0)
	remaining_seconds -= (hours * 3600.0)

	var minutes: int = floor(remaining_seconds / 60.0)
	@warning_ignore("narrowing_conversion")
	var _seconds: int = remaining_seconds - (minutes * 60.0)

	var formatted_hours := "%02d" % hours
	var formatted_minutes := "%02d" % minutes
	
	var final_string := ""
	
	if _days > 0:
		final_string += "%d days " % [_days]
	if hours > 0:
		final_string += "%s hours " % [formatted_hours]
	if minutes > 0:
		final_string += "%s minutes " % [formatted_minutes]
	if _seconds > 0:
		final_string += "%.2f seconds " % [_seconds]

	return final_string
	#return "D:%d H:%s M:%s S:%.2f" % [days, formatted_hours, formatted_minutes, seconds]
