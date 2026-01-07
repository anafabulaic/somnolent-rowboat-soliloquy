@tool
extends Control

var file_dialog: FileDialog
var current_file_path: String
var current_file: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gui := EditorInterface.get_base_control()
	
	#%TopHeader.icon = gui.get_theme_icon("FileAccess", "EditorIcons")
	
	%FilePickerHeader.icon = gui.get_theme_icon("PlaceholderTexture2D", "EditorIcons")
	%FilePickerButton.icon = gui.get_theme_icon("Load", "EditorIcons")
	%FilePickerEraser.icon = gui.get_theme_icon("Close", "EditorIcons")
	
	%MaterialCreationHeader.icon = gui.get_theme_icon("FileList", "EditorIcons")
	%MaterialCreation.visible = false
	
	file_dialog = %FilePickerDialog
	file_dialog.current_dir = "res://materials/"
	file_dialog.add_filter("*.png", "Image Files")

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var can_drop: bool = data is Dictionary and data.has('files')

	return can_drop

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var files := (data.get("files", []) as Array).filter(func(file:String): return file.get_extension() == "png")
	
	var previewer := EditorInterface.get_resource_previewer()
	for file in files:
		current_file_path = file
		current_file = load(file)
		previewer.queue_resource_preview(file, self, "_on_resource_ready", null)

func _on_resource_ready(path: String, preview: Texture2D, small_preview: Texture2D, data: Variant) -> void:
	%FilePickerTextBox.text = path
	%FileDragLabel.text = "Current file: " + path
	
	%MaterialCreation.visible = true
	%FilePickerEraser.visible = true
	%FilePreview.visible = true
	%FilePreview.texture = preview

func _on_file_picker_button_pressed() -> void:
	file_dialog.popup_centered_ratio(0.5)

func _on_file_picker_dialog_file_selected(path: String) -> void:
	var file := load(path)
	
	if !file:
		return

	var previewer := EditorInterface.get_resource_previewer()
	previewer.queue_resource_preview(path, self, "_on_resource_ready", null)
	
	current_file_path = path
	current_file = load(path)

func _on_create_material_button_pressed() -> void:
	if !current_file:
		return
	
	var current_dir := current_file_path.get_base_dir()
	var file_name := current_file_path.get_file().get_basename()
	
	var new_material := StandardMaterial3D.new()
	new_material.albedo_texture = current_file
	new_material.transparency = 2 if %TransparencyCheckBox.button_pressed else 0
	new_material.shading_mode = 0 if %EmissionCheckBox.button_pressed else 1
	new_material.cull_mode = BaseMaterial3D.CULL_DISABLED if %DoubleSideCheckBox.button_pressed else BaseMaterial3D.CULL_BACK
	
	var new_file_path := current_dir + "/" + file_name + ".tres"
	
	if FileAccess.file_exists(new_file_path):
		printerr("File already exists at ", new_file_path, ".")
		return
	
	if !ResourceSaver.save(new_material, new_file_path):
		print("Successfully created new material at ", new_file_path, ".")
		_on_file_picker_eraser_pressed()
	
	#var file := FileAccess.new()
	#file.open(current_dir, FileAccess.READ_WRITE)
	
func _on_file_picker_eraser_pressed() -> void:
	current_file_path = ""
	current_file = null
	
	%FilePickerTextBox.text = ""
	%FileDragLabel.text = "No file selected. Drag a file here to start."
	
	%MaterialCreation.visible = false
	%FilePickerEraser.visible = false
	%FilePreview.visible = false
	%FilePreview.texture = null
