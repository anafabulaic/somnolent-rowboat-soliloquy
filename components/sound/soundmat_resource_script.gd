extends Resource
class_name SoundMatResource

#@export var use_footsteps: bool = false
#@export var footsteps: Array[AudioStream]

@export_category("Impact Sounds")
@export var impacts: Array[AudioStream]
@export var impact_min_pitch: float = 1.0
@export var impact_max_pitch: float = 1.0

@export var sliding: AudioStream
