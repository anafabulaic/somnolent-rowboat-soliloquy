# meta-name: State
# meta-description: Base template for the State class for use with StateMachine components.
# meta-default: true
# meta-space-indent: 4

extends State

# NOTE: available signals in State
# signal entered(previous_state_name: String, data: Dictionary)
# signal finished(next_state_name: String, data: Dictionary)

func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	pass
	
func enter(previous_state_name: String, data: Dictionary = {}) -> void:
	pass
	
func exit() -> void:
	pass
