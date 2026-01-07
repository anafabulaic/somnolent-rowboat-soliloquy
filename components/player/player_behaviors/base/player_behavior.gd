extends Node
class_name PlayerBehavior

@onready var player: Player = self.owner
@onready var stats: PlayerStatSheet = player.stats

@export var is_enabled: bool = true

@export var state_whitelist: Array[State]
@export var state_blacklist: Array[State]

func _enter_tree() -> void:
	if self.owner is Player == false:
		push_error("PlayerBehavior must have a Player as scene root")
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
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass
		
func is_state_whitelisted() -> bool:
	if state_whitelist.size() == 0:
		return true
	elif player.get_current_state() in state_whitelist:
		return true
	else:
		return false
		
func is_state_blacklisted() -> bool:
	if state_blacklist.size() == 0:
		return false
	elif player.get_current_state() in state_blacklist:
		return true
	else:
		return false
		
func can_activate() -> bool:
	return is_enabled and is_state_whitelisted() and !is_state_blacklisted()
