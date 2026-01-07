@tool
extends EditorPlugin

var dock: STMainTool

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	dock = preload("res://addons/syuzhet_tools/tool_scene.tscn").instantiate()
	dock.name = "Syuzhet Tools"
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, dock)
	
	scene_changed.connect(propagate_scene_change)

func _exit_tree() -> void:
	scene_changed.disconnect(propagate_scene_change)
	
	remove_control_from_docks(dock)
	
	dock.queue_free()

func propagate_scene_change(scene_root: Node) -> void:
	if !dock:
		return
		
	dock.propagate_scene_change(scene_root)
