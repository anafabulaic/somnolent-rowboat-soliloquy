extends PlayerInteractable
class_name MapTrinket

@export var trinket: TrinketReference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
	if Game.trinkets.has_trinket(trinket):
		self.queue_free()
		return
	
	self.collision_layer = 0
	self.set_collision_layer_value(4, true)
	
	can_interact = true
	
func on_player_interact() -> void:
	if !Game.trinkets.has_trinket(trinket):
		var sound := System.sound.ui_ding
		
		SignalBus.ui_do_tooltip.emit("Equip Trinkets by pressing TAB!", 8.0, null)
		SignalBus.ui_do_tooltip.emit(str("Obtained Trinket - ", trinket.name), 8.0, sound)
		Game.trinkets.add_trinket(trinket)
		#Game.trinkets.equip_trinket(trinket)
	else:
		SignalBus.do_interact_error.emit()
