extends Node3D
class_name TemporaryEffect

var effects: Array[CPUParticles3D]
var num_children: int = 0
var effects_finished: int = 0

@export var use_lifetime: bool = false
@export var max_lifetime: float = 1.0
@export var max_emission_time: float = 1.0
var lifetime: float = 0.0

var is_emitting: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for particle: CPUParticles3D in self.get_children():
		num_children += 1
		effects.append(particle)
		if not use_lifetime:
			particle.finished.connect(particle_finished)

	for particle: CPUParticles3D in effects:
		particle.emitting = true

	is_emitting = true

func _process(delta: float) -> void:
	if use_lifetime:
		lifetime += delta
		if lifetime >= max_emission_time and is_emitting:
			is_emitting = false
			for effect in effects:
				effect.emitting = false

		if lifetime >= max_lifetime:
			for effect in effects:
				effect.queue_free()
			effects.clear()

func particle_finished() -> void:
	effects_finished += 1

	if effects_finished >= num_children:
		self.queue_free()
