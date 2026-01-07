extends State
class_name PlayerState

@onready var state_machine: PlayerStateMachine = self.get_parent()
@onready var player: Player = self.owner

func _enter_tree() -> void:
	if self.owner is Player == false:
		push_error("PlayerState must have a Player as scene root")
		return
	elif self.get_parent() is PlayerStateMachine == false:
		push_error("PlayerState must be inside a PlayerStateMachine")
		return

func is_grounded() -> bool:
	return false
