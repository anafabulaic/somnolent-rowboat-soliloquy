extends Node
class_name PlayerActionManager

var actions: Dictionary = {}

func init() -> void:
	get_all_actions(self)

func get_all_actions(node: Node) -> void:
	for child in node.get_children():
		if child is PlayerAction:
			actions[child.name] = child
			child.init()

func handle_actions_input(event: InputEvent) -> void:
	for action: PlayerAction in actions.values():
		if action.can_execute():
			action.handle_input(event)
	
func process_actions_physics(delta: float) -> void:
	for action: PlayerAction in actions.values():
		if action.can_execute():
			action.update_physics(delta)

func trigger(action_name: String) -> void:
	var action: PlayerAction = actions.get(action_name)
	
	if actions.get(action_name) == null:
		push_error("Tried to get non-existent action ", action_name)
		return
	
	if action.can_execute():
		action.trigger()
	
