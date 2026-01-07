extends Node
class_name PlayerBehaviorManager

var behaviors: Dictionary = {}

func _ready() -> void:
	pass
	
func init() -> void:
	get_all_behaviors(self)
			
func get_all_behaviors(node: Node) -> void:
	for child in node.get_children():
		if child is PlayerBehavior and child.is_enabled:
			behaviors[child.name] = child
			child.init()
		if child.get_child_count() > 0:
			get_all_behaviors(child)
			
func activate(behavior: String) -> void:
	behaviors.get(behavior).is_activated = true
	
func deactivate(behavior: String) -> void:
	behaviors.get(behavior).is_activated = false
	
func get_behavior(behavior: String) -> PlayerBehavior:
	if behaviors.has(behavior):
		return behaviors.get(behavior)
	else:
		push_error("Tried to get invalid behavior ", behavior)
		return null
	
func handle_behavior_input(event: InputEvent) -> void:
	for behavior: PlayerBehavior in behaviors.values():
		if behavior.can_activate():
			behavior.handle_input(event)
		
func process_behaviors(delta: float) -> void:
	for behavior: PlayerBehavior in behaviors.values():
		if behavior.can_activate(): behavior.update(delta)

func process_behaviors_physics(delta: float) -> void:
	for behavior: PlayerBehavior in behaviors.values():
		if behavior.can_activate(): behavior.physics_update(delta)
