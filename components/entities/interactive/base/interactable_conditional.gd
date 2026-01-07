extends PlayerInteractable
class_name PlayerInteractableConditional

signal on_interact_succeed
signal on_interact_fail

enum ConditionModes {
	ConditionsAsFilter, ## Conditions will act as a filter to determine whether we can interact with this or not.
	ConditionsActivateChildren, ## Conditions will activate their children.
	ConditionsActivateChildrenExclusive ## The first condition to be met will activate its children then return. I got carried away, so this is basically a decision tree.
}

## How this interactable behaves
@export var condition_mode: ConditionModes = ConditionModes.ConditionsAsFilter

## Use the default UI effects
@export var use_ui_success: bool = true
@export var use_ui_failure: bool = true

@export var interact_delay: float = 0.5
var last_interact: int = -9999

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func get_conditions(con: Node) -> Array[InteractCondition]:
	var interact_array: Array[InteractCondition] = []

	for node in con.find_children("*", "InteractCondition", false) as Array[InteractCondition]:
		if node is InteractCondition:
			interact_array.append(node)
			
	return interact_array

func process_conditions() -> bool:
	var final_return: bool = true
	
	for condition: InteractCondition in get_conditions(self):
		final_return = condition.get_condition()
		
	return final_return

func on_player_interact() -> void:
	if !handle_delay():
		return
	
	var condition_success: bool = false
	
	match condition_mode:
		ConditionModes.ConditionsAsFilter:
			condition_success = handle_mode_condition_filter()
		ConditionModes.ConditionsActivateChildren:
			condition_success = handle_mode_condition_children(self, self, false)
		ConditionModes.ConditionsActivateChildrenExclusive:
			condition_success = handle_mode_condition_children(self, self, true)

	if condition_success and use_ui_success:
		SignalBus.do_interact_bounce.emit()
	elif use_ui_failure:
		SignalBus.do_interact_error.emit()

func handle_delay() -> bool:
	if last_interact == -9999: 
		last_interact = Time.get_ticks_msec()
		return true
	
	if (Time.get_ticks_msec() - last_interact) < (interact_delay * 1000):
		return false
	else:
		last_interact = Time.get_ticks_msec()
		return true

func handle_mode_condition_filter() -> bool:
	if !process_conditions():
		on_interact_fail.emit()
		_on_interact_fail()
		return false
	
	on_interact_succeed.emit()
	_on_interact_succeed()
	return true

static func handle_mode_condition_children(owner_node: Node, caller: Node, exclusive: bool) -> bool:
	if !(caller == owner_node or\
	 caller is InteractCondition or\
	(caller is InteractCondition and caller.reference)):
		return false
	
	#print("Entered this method from ", caller.name)
	
	var did_any_effects_trigger: bool = false
	
	for child in caller.get_children():
		#print(child.name)
		if child is InteractCondition and child.reference:
			continue
		elif child is InteractCondition and !child.get_condition():
			#print(child.name, " failed! Continuing")
			continue
		elif child is InteractableEffect and !child.reference and child.enabled:
			child.trigger()
			did_any_effects_trigger = true
			
			if exclusive:
				return true
				
			continue
		
		if handle_mode_condition_children(owner_node, child, exclusive):
			did_any_effects_trigger = true
			if exclusive:
				return true
		
	return did_any_effects_trigger

func _on_interact_succeed() -> void:
	pass
	
func _on_interact_fail() -> void:
	pass
