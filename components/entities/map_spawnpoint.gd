extends Marker3D
class_name MapSpawnPoint

@export var spawn_point_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_to_group("Spawnpoints")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
