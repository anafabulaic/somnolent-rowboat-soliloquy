extends GridContainer
class_name TrinketContainer

@export var trinket_selection_scene: PackedScene

var trinkets: Dictionary[TrinketReference, TrinketSelection]

var current_equipped_selection: TrinketSelection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.on_trinket_add.connect(add_trinket)
	SignalBus.on_trinket_remove.connect(remove_trinket)
	SignalBus.on_trinket_equipped.connect(equip_trinket)
	SignalBus.on_trinket_unequipped.connect(unequip_trinket)
	SignalBus.clear_trinkets.connect(clear_trinkets)

func add_trinket(trinket: TrinketReference) -> void:
	if has_trinket(trinket):
		return
	
	var new_trinket_select: TrinketSelection = trinket_selection_scene.instantiate()
	
	new_trinket_select.trinket_ref = trinket
	
	new_trinket_select.set_icon(trinket.icon)
	new_trinket_select.set_title(trinket.name)
	new_trinket_select.set_desc(trinket.desc)
	
	trinkets[trinket] = new_trinket_select
	
	add_child(new_trinket_select)
	
	sort_children_alphabetically()
	
func remove_trinket(trinket: TrinketReference) -> void:
	if !has_trinket(trinket):
		return
	
	trinkets[trinket].queue_free()
	trinkets.erase(trinket)
	
	sort_children_alphabetically()

func clear_trinkets() -> void:
	for i in get_children():
		i.queue_free()
		
	trinkets = {}
	current_equipped_selection = null

func has_trinket(trinket: TrinketReference) -> bool:
	return trinket in trinkets.keys()

func equip_trinket(trinket: TrinketReference) -> void:
	if !has_trinket(trinket):
		return
	
	if current_equipped_selection:
		current_equipped_selection.set_equipped(false)
	
	sort_children_alphabetically()
	
	current_equipped_selection = trinkets[trinket]
	current_equipped_selection.set_equipped(true)
	#move_child(current_equipped_selection, 0)
	
func unequip_trinket(trinket: TrinketReference) -> void:
	if !has_trinket(trinket):
		return
	
	if current_equipped_selection:
		current_equipped_selection.set_equipped(false)
		current_equipped_selection = null
	
	sort_children_alphabetically()
	
	trinkets[trinket].set_equipped(false)

func sort_children_alphabetically() -> void:
	var sorted_children := get_children()
	
	sorted_children.sort_custom(func(a: TrinketSelection, b: TrinketSelection) -> bool:
		return a.name.naturalnocasecmp_to(b.name) < 0)
	
	for i in range(sorted_children.size()):
		var node := sorted_children[i]
		move_child(node, i)		
