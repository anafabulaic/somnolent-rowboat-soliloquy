@tool
extends Control

var current_scene: Node
var current_occluder: OccluderInstance3D
var current_lightmap: LightmapGI

func _ready() -> void:
	var gui := EditorInterface.get_base_control()

	%QuickBakerHeader.icon = gui.get_theme_icon("PlaceholderTexture3D", "EditorIcons")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_scene_changed(scene_root: Node) -> void:
	current_lightmap = null
	current_occluder = null
	current_scene = scene_root

	%SceneNameLabel.text = "Current scene: " + scene_root.scene_file_path.get_file()
	#print("Scene changed to ", scene_root.name, " | ", scene_root.get_child_count())
	
	find_lightmap_node(scene_root)
	find_occluder_node(scene_root)

func find_lightmap_node(scene_root: Node) -> void:
	var lightmap := scene_root.find_children("*", "LightmapGI") as Array[Node]
	
	if lightmap:
		current_lightmap = lightmap[0]
		%LightmapBakeButton.visible = true
		
		refresh_selection(lightmap[0])
		#print("Found a LightmapGI node named ", lightmap[0].name)
	else:
		current_lightmap = null
		%LightmapBakeButton.visible = false
		
func find_occluder_node(scene_root: Node) -> void:
	var occluder := scene_root.find_children("*", "OccluderInstance3D") as Array[Node]
	
	if occluder:
		current_occluder = occluder[0]
		%OccluderBakeButton.visible = true
		
		refresh_selection(occluder[0])
		#print("Found an OccluderInstance3D node named ", occluder[0].name)
	else:
		current_occluder = null
		%OccluderBakeButton.visible = false

func _on_lightmap_bake_button_pressed() -> void:
	if !current_scene or !current_lightmap:
		printerr("Scene or LightmapGI are missing.")
		current_scene = null
		current_lightmap = null
		
		%LightmapBakeButton.visible = false
		
		return

	var root := EditorInterface.get_base_control()
	find_children_recursive(root, "Bake Lightmaps")
	
func _on_occluder_bake_button_pressed() -> void:
	if !current_scene or !current_occluder:
		printerr("Scene or OccluderInstance3D are missing.")
		current_scene = null
		current_occluder = null
		
		%OccluderBakeButton.visible = false
		
		return

	var root := EditorInterface.get_base_control()
	find_children_recursive(root, "Bake Occluders")

## imperceptibly selects the occluder/lightmap nodes in the current scene.[br]
## for some reason, you need to do this when switching scenes or else it might try to bake the other scene instead.[br]
## this is stupid as fuck but it's not my fault!
func refresh_selection(selected_node: Node) -> void:
	var sel: EditorSelection = EditorInterface.get_selection()
	var prev_sel := sel.get_selected_nodes()
	
	EditorInterface.edit_node(selected_node)
	
	sel.clear()
	
	for node in prev_sel:
		sel.add_node(node)
		EditorInterface.edit_node(node)

## recurses through the entire editor scene tree and looks for a [Button] with the given string. [br][br]
## this is probably a stupid ass way to do this, but i've been left with no choice!
func find_children_recursive(root: Node, search_string: String) -> void:
	for child in root.get_children():
		if child is Button:
			var btn: Button = child
			if btn.text.contains(search_string) and btn.icon:
				#print(btn)
				#print(btn.text, " | ", search_string, " | ", btn.text.contains(search_string))
				btn.pressed.emit()
				return
		else:
			find_children_recursive(child, search_string)
