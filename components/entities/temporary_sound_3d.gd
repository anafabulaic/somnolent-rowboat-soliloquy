extends AudioStreamPlayer3D
class_name TemporarySound3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.finished.connect(delete)
	
	if !stream:
		delete()
	
	play()
	
func delete() -> void:
	self.queue_free()
