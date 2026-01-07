extends Node
class_name StateMachine

@export var default_state: State

@onready var current_state: State = default_state
var previous_state: State

var states: Dictionary

func _ready() -> void:
	if get_child_count() == 0:
		push_error("State Machine ", name, " has no states.")
		return
	elif default_state == null:
		push_error("No default state set for State Machine ", name)
		return
		
	for state in get_children():
		states[state.name] = state
		state.finished.connect(set_state)
	
	set_state(default_state.name)
	
func process_states(delta: float) -> void:
	if current_state:
		current_state.update(delta)
		
func process_states_physics(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
	
func set_state(desired_state_name: String, data: Dictionary = {}) -> void:
	if states.size() < 1:
		push_error("Could not set state ", desired_state_name, " because State Machine ", name, " is empty.")
		return
	elif states.has(desired_state_name) == null:
		push_error("Tried setting non-existent state ", desired_state_name, " in State Machine ", name)
		return
	elif states.size() == 1:
		push_error("Tried setting a state in State Machine ", name, ", which only has one state.")
		return
		
	previous_state = current_state
	
	current_state.exit()
	current_state = states[desired_state_name]
	
	current_state.enter(previous_state.name, data)
	current_state.entered.emit(previous_state.name, data)
	
func undo_state(data: Dictionary = {}) -> void:
	set_state(previous_state.name, data)
