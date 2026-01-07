@tool
extends EditorScenePostImport

var material_list: Dictionary

var default_soundmat := load("res://sounds/soundmat/default.tres")
var default_water_material := load("res://materials/water/water_material.tres")

func _post_import(scene: Node) -> Object:	
	_init_material_list()
	
	if scene.get_child_count() == 0:
		return
	
	_process_child(scene)
	_set_owner(scene, scene)
	
	return scene

func _process_child(child: Node) -> void:
	for sub_child in child.get_children():
		_process_child(sub_child)
	_process_type(child)

func _process_type(child: Node) -> void:
	if child is MeshInstance3D:
		_process_mesh(child)
		
	if !get_source_file().get_base_dir().contains("maps"):
		print("Import doesn't seem like a level.")
		if child is VisualInstance3D:
			var vis: GeometryInstance3D = child
			vis.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
			vis.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
			vis.layers = 0
			vis.set_layer_mask_value(2, true)
		
		return
	
	if child is Light3D and child.name.contains("-light"):
		_process_light(child)
	if child.name.contains("-spawnpoint"):
		_process_spawnpoint(child)
	if child.name.ends_with("-detail"):
		_process_detail(child)
	if child.name.contains("-water"):
		_process_water(child)
	if child.name.contains("-foliage"):
		_process_foliage(child)
	if child.name.ends_with("-ladder"):
		_process_ladder(child)
	if child is RigidBody3D:
		_process_rigidbody(child)

func _init_material_list() -> void:
	material_list = get_all_files("res://", "tres")

func _process_spawnpoint(node: Node3D) -> void:
	var new_node: MapSpawnPoint = MapSpawnPoint.new()
	new_node.name = node.name
	new_node.transform = node.transform
	
	node.replace_by(new_node)
	new_node.add_to_group("Spawnpoints")
	
func _process_detail(node: Node3D) -> void:
	if node is GeometryInstance3D:
		var vis: GeometryInstance3D = node
		#vis.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		vis.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
		#vis.layers = 0
		#vis.set_layer_mask_value(2, true)
		
func _process_foliage(node: Node3D) -> void:
	if node is GeometryInstance3D:
		var vis: GeometryInstance3D = node
		vis.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		#vis.visibility_range_begin = 10.0
		#vis.visibility_range_end = 30.0
		#vis.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		#vis.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		#vis.gi_lightmap_texel_scale = 0.1
		vis.layers = 0
		vis.set_layer_mask_value(2, true)
		
func _process_ladder(node: Node3D) -> void:
	if node is MeshInstance3D:
		var collider_node := CollisionShape3D.new()
		collider_node.name = node.name + "_collider"
		node.add_child(collider_node)
		var collider_mesh: Mesh = node.mesh
		collider_node.shape = collider_mesh.create_convex_shape()

	var new_prop: Ladder = Ladder.new()
	new_prop.name = node.name
	new_prop.transform = node.transform
	
	node.replace_by(new_prop, true)
	
	new_prop.collision_layer = 0
	new_prop.collision_mask = 0

	new_prop.set_collision_mask_value(32, true)
	
	for child in new_prop.get_children():
		if child is Node3D and child.name.contains("ladder_empty"):
			var empty: Node3D = child
			new_prop.normal_empty = empty
			new_prop.normal = (new_prop.transform * empty.transform).basis.y
			#new_prop.normal = new_prop.normal.normalized()

func _process_light(node: Light3D) -> void:
	node.light_bake_mode = Light3D.BAKE_STATIC
	
	#if node.has_meta("extras"):
		#var custom_properties: Dictionary = node.get_meta("extras")
		#if custom_properties.has("light-power"):
			#print(custom_properties["light-power"])
			#node.light_energy = custom_properties["light-power"]
		
func _process_water(node: Node3D) -> void:
	if node is MeshInstance3D:
		var collider_node := CollisionShape3D.new()
		collider_node.name = node.name + "_collider"
		node.add_child(collider_node)
		var collider_mesh: Mesh = node.mesh
		collider_node.shape = collider_mesh.create_convex_shape()
		
	var new_prop: MapWaterVolume = MapWaterVolume.new()
	new_prop.name = node.name
	new_prop.transform = node.transform
	
	var new_mesh_instance: MeshInstance3D = MeshInstance3D.new()
	new_mesh_instance.mesh = node.mesh
	new_mesh_instance.name = node.name + "_mesh"
	_process_mesh(new_mesh_instance)
	node.add_child(new_mesh_instance)
	
	node.replace_by(new_prop, true)

	new_prop.collision_layer = 0
	new_prop.collision_mask = 0

	new_prop.set_collision_mask_value(2, true)
	new_prop.set_collision_mask_value(32, true)

	for child in new_prop.get_children():
		if child is GeometryInstance3D:
			var vis_child: GeometryInstance3D = child
			vis_child.material_override = default_water_material
			vis_child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			vis_child.gi_mode = GeometryInstance3D.GI_MODE_DISABLED

func _process_rigidbody(node: RigidBody3D) -> PhysicsProp3D:
	node.collision_layer = 0
	node.collision_mask = 0
	
	node.set_collision_layer_value(2, true)
	
	node.set_collision_mask_value(1, true)
	node.set_collision_mask_value(2, true)
	
	for child in node.get_children():
		if child is GeometryInstance3D:
			var vis_child: GeometryInstance3D = child
			vis_child.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	
	var bounding_box: AABB = Util.get_aabb(node)
	var bbox: Vector3 = bounding_box.size * node.scale
	var automass: float = bbox.x * bbox.y * bbox.z
	var mass_mult: float = 10.0
	
	node.mass = automass * mass_mult
	return node

func _process_mesh(node: MeshInstance3D) -> void:
	var mesh: Mesh = node.mesh
	for idx in mesh.get_surface_count():
		var material_name := mesh.surface_get_material(idx).resource_name + ".tres"
		if material_list.get(material_name):
			mesh.surface_set_material(idx, load(material_list[material_name]))

func _set_owner(node: Node, owner: Node) -> void:
	if node.get_owner() != owner:
		node.set_owner(owner)
	for child in node.get_children():
		_set_owner(child, owner)
	pass	
		
func get_all_files(path: String, file_ext := "", files: Dictionary = {}) -> Dictionary:
	var dir: DirAccess = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()

		var file_name: String = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir() + "/" + file_name, file_ext, files)
			else:
				if file_ext and file_name.get_extension() and file_name.trim_suffix(".remap").get_extension() and file_name.trim_suffix(".import").get_extension() != file_ext:
					file_name = dir.get_next()
					continue
				if file_name.get_extension() == "remap":
					file_name = file_name.trim_suffix(".remap")
				elif file_name.get_extension() == "import":
					file_name = file_name.trim_suffix(".import")
				files[file_name] = dir.get_current_dir() + "/" + file_name

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)

	return files
