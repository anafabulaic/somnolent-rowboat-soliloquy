extends Control
class_name UIToolTip

@export var icon: Texture2D
@export var text: String
@export var expiration_time: float = 4.0

var self_pos: Vector2
var container_following_self: bool = true

func _ready() -> void:
	SignalBus.ui_cancel_tooltip.connect(cancel)
	
	if icon:
		%IconTexture.texture = icon
	
	if text:
		%IconText.text = text

	%Container.top_level = true
	%Container.global_position = get_viewport_rect().size
	#%Container.global_position = self.global_position + (Vector2.RIGHT * 50)
	
	await Main.wait(expiration_time)
	disappear()

var velocity: Vector2 = Vector2.ZERO
var stiffness: float = 10.0
var damping: float = 0.4

func _physics_process(delta: float) -> void:
	self.custom_minimum_size = %Container.size
	if container_following_self:
		var displacement: Vector2 = (self.global_position - %Container.global_position)
		var spring_force: Vector2 = displacement * stiffness
		velocity += spring_force * delta
		velocity = velocity.move_toward(Vector2.ZERO, velocity.length() * damping * delta * 60)
		
		%Container.global_position += velocity

func disappear() -> void:
	container_following_self = false
	
	var tween := self.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(%Container, "position", %Container.position + (Vector2.RIGHT * 400), 0.5)
	tween.tween_callback(delete)

func cancel(txt: String) -> void:
	if txt == text:
		self.disappear()

func delete() -> void:
	self.queue_free()
