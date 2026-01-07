extends StateMachine
class_name PlayerStateMachine

@onready var player: Player = self.owner

func _enter_tree() -> void:
	if self.owner is Player == false:
		push_error("PlayerStateMachine must have a Player as scene root")
		return
