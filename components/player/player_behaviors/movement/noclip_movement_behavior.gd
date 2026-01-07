extends PlayerBehavior
class_name PlayerNoclipMovementBehavior

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("noclip"):
		if player.get_current_state() is not PlayerNoclipState and Game.cheats:
			player.set_state("PlayerNoclipState")
		else:
			player.set_state("PlayerFallingState")
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	if player.get_current_state() is not PlayerNoclipState:
		return
		
	#DebugDraw3D.draw_line(player._camera_head.global_position, player._camera_head.global_position + player.get_camera_dir(), Color.RED, 0.1)
	stats.velocity = player.get_camera_wish_dir() * (stats.wish_speed * 0.1)
	if Input.is_action_pressed("sprint"):
		stats.velocity *= 2.0
	
	if Input.is_action_pressed("jump"):
		stats.velocity.y = (stats.wish_speed * 0.1)
