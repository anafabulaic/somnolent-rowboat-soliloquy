extends Node3D
class_name PlayerTrinketManager

@export var player: Player = self.owner

var equipped_trinket: TrinketReference
var equipped_trinket_node: Trinket

var trinkets: Dictionary[TrinketReference, Trinket] = {}

func init() -> void:
	SignalBus.on_premove.connect(do_trinket_stats_premove)
	SignalBus.on_postmove.connect(do_trinket_stats_postmove)
	
	SignalBus.on_trinket_add.connect(add_trinket)
	SignalBus.on_trinket_remove.connect(remove_trinket)
	SignalBus.on_trinket_equipped.connect(equip_trinket)
	SignalBus.on_trinket_unequipped.connect(unequip_trinket)
	
	if Game.current_save and !Game.current_save.trinkets.is_empty():
		for trinket: String in Game.current_save.trinkets:
			Game.trinkets.add_trinket_by_name(trinket)
	
	#if Game.current_save and !Game.current_save.trinkets.is_empty():
		#for trinket_name in Game.current_save.trinkets:
			#if System.trinket_library.has(trinket_name):
				#add_trinket_by_name(trinket_name)

func add_trinket(item: TrinketReference) -> void:
	if has_trinket(item) or item in trinkets.keys():
		return
	
	var new_trinket: Trinket = item.trinket_scene.instantiate()
	
	new_trinket.player = player
	new_trinket.stats = player.stats
	new_trinket.ref = item
	
	self.add_child(new_trinket)
	
	#SignalBus.on_trinket_add.emit(item)
	
	trinkets[item] = new_trinket
	new_trinket.init()

func add_trinket_by_name(trinket_name: String) -> void:
	if System.trinket_library.is_empty() or !System.trinket_library.has(trinket_name):
		return
		
	var load_trinket_path := ResourceUID.ensure_path(System.trinket_library[trinket_name])
	var loaded_trinket := load(load_trinket_path)
	
	if loaded_trinket:
		add_trinket(loaded_trinket)

func remove_trinket(item: TrinketReference) -> void:
	if !has_trinket(item) or !(item in trinkets.keys()):
		return
	
	unequip_trinket(item)
	trinkets[item].queue_free()
	trinkets.erase(item)
	
	#SignalBus.on_trinket_remove.emit(item)

func equip_trinket(item: TrinketReference) -> void:
	if !has_trinket(item):
		return
	
	item.is_equipped = true
	
	player.stats.equipped_trinket = item
	equipped_trinket = item
	equipped_trinket_node = trinkets[item]
	
	trinkets[item].is_enabled = true
	trinkets[item].on_equip()
	
	#SignalBus.on_trinket_equipped.emit(item)
	
func unequip_trinket(item: TrinketReference) -> void:
	if !has_trinket(item):
		return
	
	item.is_equipped = false
	
	player.stats.equipped_trinket = null
	equipped_trinket = null
	equipped_trinket_node = null
	
	trinkets[item].is_enabled = false
	trinkets[item].on_unequip()
	
	#SignalBus.on_trinket_unequipped.emit(item)

func get_equipped_trinket() -> TrinketReference:
	return equipped_trinket

func is_trinket_equipped(item: TrinketReference) -> bool:
	return item.is_equipped

func has_trinket(item: TrinketReference) -> bool:
	return trinkets.has(item)
	#for trinket: TrinketReference in trinkets.keys():
		#if trinket.id == item.id:
			#return true
	#
	#return false

func handle_trinkets_input(event: InputEvent) -> void:
	for trinket: Trinket in trinkets.values():
		if trinket.is_enabled and equipped_trinket_node == trinket:
			trinket.handle_input(event)
			if event.is_action("primaryfire") and event.is_pressed() and !event.is_echo():
				trinket.trigger()
	
func process_trinkets(delta: float) -> void:
	for trinket: Trinket in trinkets.values():
		if trinket.is_enabled:
			trinket.update(delta)

func process_trinkets_physics(delta: float) -> void:
	for trinket: Trinket in trinkets.values():
		if trinket.is_enabled:
			trinket.update_physics(delta)

func do_trinket_stats_premove(stats: PlayerStatSheet, delta: float) -> void:
	for trinket: Trinket in trinkets.values():
		if trinket.is_enabled and equipped_trinket_node == trinket:
			trinket.do_stats_premove(stats)
			
func do_trinket_stats_postmove(stats: PlayerStatSheet, delta: float) -> void:
	for trinket: Trinket in trinkets.values():
		if trinket.is_enabled and equipped_trinket_node == trinket:
			trinket.do_stats_postmove(stats)
