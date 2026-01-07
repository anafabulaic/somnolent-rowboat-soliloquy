extends PlayerBehavior
class_name PlayerFlashlightBehavior

@export var flashlight: SpotLight3D
@export var flashlight_sound: AudioStreamPlayer2D

@export var flashlight_energy: float = 1.0
# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet
var flashlight_enabled: bool = false
var tween: Tween

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("flashlight"):
		flashlight_enabled = !flashlight_enabled
		
		flashlight_sound.pitch_scale = 0.6 if flashlight_enabled else 0.4
		flashlight_sound.play()
		#flashlight.visible = flashlight_enabled
		
		if flashlight_enabled:
			flashlight_up()
		else:
			flashlight_down()

func flashlight_up() -> void:
	if tween: tween.kill()
	
	flashlight.visible = true
	
	tween = player.create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(flashlight, "spot_angle", 40.0, 0.2)
	tween.tween_property(flashlight, "light_energy", flashlight_energy, 0.1)
	tween.set_parallel(false)
	tween.tween_property(flashlight, "light_energy", flashlight_energy * 0.4, 0.02)
	tween.tween_property(flashlight, "light_energy", flashlight_energy, 0.02)
	
func flashlight_down() -> void:
	if tween: tween.kill()
	
	tween = player.create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(flashlight, "light_energy", 0.0, 0.1)
	tween.tween_property(flashlight, "spot_angle", 10.0, 0.1)
	tween.set_parallel(false)
	tween.tween_property(flashlight, "visible", false, 0.1)

func set_flashlight(angle: float) -> void:
	flashlight.spot_angle = angle
