extends Node
class_name TrinketManager

@export var trinkets: Array[TrinketReference]
@export var current_trinket: TrinketReference

func _ready() -> void:
	pass

func has_trinket(item: TrinketReference) -> bool:
	return trinkets.has(item)

## more accurately, add trinket by ID
func add_trinket_by_name(trinket_name: String) -> void:
	if System.trinket_library.is_empty() or !System.trinket_library.has(trinket_name):
		return
		
	var load_trinket_path := ResourceUID.ensure_path(System.trinket_library[trinket_name])
	var loaded_trinket := load(load_trinket_path)
	
	if loaded_trinket:
		add_trinket(loaded_trinket)

func add_trinket(item: TrinketReference) -> void:
	if has_trinket(item):
		return
	
	if Game.current_save:
		if !Game.current_save.trinkets.has(item.id):
			print("Added trinket named ", item.id, " to our record!")
			Game.current_save.trinkets.append(item.id)
	
	trinkets.append(item)
	SignalBus.on_trinket_add.emit(item)

func remove_trinket(item: TrinketReference) -> void:
	if !has_trinket(item):
		return
		
	trinkets.erase(item)
	SignalBus.on_trinket_remove.emit(item)
	
func clear_trinkets() -> void:
	if current_trinket:
		unequip_current_trinket()
	
	trinkets = []
	current_trinket = null
	
	SignalBus.clear_trinkets.emit()

func equip_trinket(item: TrinketReference) -> void:
	if !has_trinket(item):
		return
		
	current_trinket = item
	SignalBus.on_trinket_equipped.emit(item)
	
func unequip_trinket(item: TrinketReference) -> void:
	if !has_trinket(item) or current_trinket != item:
		return
	
	current_trinket = null
	SignalBus.on_trinket_unequipped.emit(item)
	
func unequip_current_trinket() -> void:
	if !current_trinket:
		return
	
	var curr_trinket_ref := current_trinket
	
	current_trinket = null
	SignalBus.on_trinket_unequipped.emit(curr_trinket_ref)

func is_trinket_equipped(item: TrinketReference) -> bool:
	return current_trinket == item

func get_owned_trinket_names() -> Array:
	if trinkets.is_empty():
		return []
	
	var trinket_id_array: Array[String] = []
		
	for trinket in trinkets:
		if trinket is TrinketReference:
			if trinket.id:
				trinket_id_array.append(trinket.id)
	
	return trinket_id_array	
	
