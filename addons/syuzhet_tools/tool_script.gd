@tool
extends Control
class_name STMainTool

signal scene_changed(scene_root: Node)

@export var quick_mat: Control
@export var quick_bake: Control

func propagate_scene_change(scene_root: Node) -> void:
	scene_changed.emit(scene_root)
