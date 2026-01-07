extends WorldEnvironment
class_name ImageSkyEnvironment

var shader_mat: ShaderMaterial

func _ready() -> void:
	if !self.environment or !self.environment.sky:
		return
		
	if self.environment.sky.sky_material is ShaderMaterial:
		shader_mat = self.environment.sky.sky_material
		shader_mat.set_shader_parameter("viewport_size", get_viewport().get_visible_rect().size)

func _process(delta: float) -> void:
	if shader_mat and Game.player:
		shader_mat.set_shader_parameter("cam_x", -Game.player._camera.global_rotation.x)
		shader_mat.set_shader_parameter("cam_y", Game.player._camera.global_rotation.y)
