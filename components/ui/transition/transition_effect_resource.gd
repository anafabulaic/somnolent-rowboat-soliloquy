extends Resource
class_name TransitionEffectResource

@export var transition_material: ShaderMaterial

## Enable if you want the effect to be split into a fade in and a fade out.
@export var use_double_sided_fade: bool = false
@export var fade_time: float = 1.0
@export var fade_in: float = 0.5
@export var fade_out: float = 0.5
