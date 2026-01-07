## This is dangerous and slow. Use sparingly!
extends InteractableEffect
class_name InteractableEffectTriggerMethod

@export var target: Node
@export var method_name: String
@export var method_args: Array

func _effect() -> void:
	if !target or !method_name:
		return
	
	if !target.has_method(method_name):
		var err := str("The TriggerMethod target named ", target.name, " does not have a method called ", method_name)
		printerr(err)
		LimboConsole.error(err)
	
	var method_count := target.get_method_argument_count(method_name)
	var method_dict: Dictionary = {}
	
	if method_count > 0 or method_args.size() != method_count:
		for i: Dictionary in target.get_method_list():
			if i["name"] == method_name:
				method_dict = i
				break

		if method_dict.is_empty():
			var err := str("Method count mismatch in TriggerMethod named ", self.name, " calling for method ", method_name)
			printerr(err)
			LimboConsole.error(err)
			return

		for arg in method_count:
			var method_arg_type: int = method_dict["args"][arg]["type"]
			var array_arg_type: int = typeof(method_args[arg])
			
			if type_string(array_arg_type) == "NodePath":
				var node_from_path := get_node(method_args[arg])
				if !node_from_path:
					var err := str("Invalid node in TriggerMethod named ", self.name)
					printerr(err)
					LimboConsole.error(err)
					return
				array_arg_type = typeof(node_from_path)
			
			#print("method: ", type_string(method_arg_type), " | ours: ", type_string(array_arg_type))
			if type_string(method_arg_type) == type_string(array_arg_type):
				continue
			else:
				var err := str("Argument mismatch in TriggerMethod named ", self.name, " calling for method ", method_name)
				printerr(err)
				LimboConsole.error(err)
				return
		
		target.callv(method_name, method_args)
	elif method_count == 0 and method_args.is_empty():
		target.call(method_name)
