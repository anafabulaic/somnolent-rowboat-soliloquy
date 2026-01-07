extends Node
class_name PlayerAction

@export var is_enabled: bool = true
@export var state_whitelist: Array[State]
@export var state_blacklist: Array[State]

var processing: bool = false

@onready var player: Player = self.owner
@onready var stats: PlayerStatSheet = player.stats

func _enter_tree() -> void:
	if self.owner is Player == false:
		push_error("PlayerAction must have a Player as scene root")
		return
		
	var ply: Player = self.owner
	
	if !ply.stats:
		push_error("Player must have a PlayerStatSheet!")
		return
		
	process_mode = Node.PROCESS_MODE_DISABLED
		
func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	pass
	
func update_physics(delta: float) -> void:
	pass

func trigger() -> void:
	if can_execute():
		execute()
		
func can_use() -> bool:
	return true
	
func is_state_whitelisted() -> bool:
	if state_whitelist.size() == 0:
		return true
	elif player.state_machine.current_state in state_whitelist:
		return true
	else:
		return false
		
func is_state_blacklisted() -> bool:
	if state_blacklist.size() == 0:
		return false
	elif player.state_machine.current_state in state_blacklist:
		return true
	else:
		return false
		
func can_execute() -> bool:
	return is_enabled and can_use() and is_state_whitelisted() and !is_state_blacklisted()
	
func execute() -> void:
	pass
