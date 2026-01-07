extends Resource
class_name TrinketReference

@export var id: String
@export var name: String
@export var icon: Texture2D
@export var desc: String

@export var trinket_scene: PackedScene

var is_equipped: bool = false

func validate() -> bool:
	if !id or !name or !icon or !desc or !trinket_scene:
		return false
	else:
		return true
