extends Node3D
class_name Trinket

@export var is_enabled: bool = false

var player: Player
var stats: PlayerStatSheet
var ref: TrinketReference

func _enter_tree() -> void:
	#if self.owner is Player == false:
		#push_error("Trinket must have a Player as scene root")
		#return
		#
	#var ply: Player = self.owner
	#
	#if !ply.stats:
		#push_error("Trinket must have a PlayerStatSheet!")
		#return
		#
	process_mode = Node.PROCESS_MODE_DISABLED

func init() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func update_physics(delta: float) -> void:
	pass

func trigger() -> void:
	if can_execute():
		SignalBus.on_trinket_use.emit(ref)
		execute()
	else:
		SignalBus.do_interact_error.emit()
		
func can_use() -> bool:
	return true
	
func can_execute() -> bool:
	return is_enabled and can_use()
	
func execute() -> void:
	pass
	
func on_equip() -> void:
	pass
	
func on_unequip() -> void:
	pass

func do_stats_premove(_stats: PlayerStatSheet) -> void:
	pass

func do_stats_postmove(_stats: PlayerStatSheet) -> void:
	pass
