extends PlayerAction
class_name PlayerJumpAction

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

signal jumped

var queued_jump: bool = false

func init() -> void:
	pass
	
func handle_input(event: InputEvent) -> void:
	if stats.wants_jump:
		execute()
	
func update_physics(delta: float) -> void:
	if player.is_grounded() and queued_jump and can_execute():
		jump(delta)
		queued_jump = false

func execute() -> void:
	queue_jump()

func jump(delta: float) -> void:
	jumped.emit()
	
	var jump_force: float = stats.jump_force
	
	# player gets stuck on the ground while jumping up slopes if we don't do this
	if !stats.touching_physics and has_space_above_head():
		player.global_position.y += 0.1
		
	stats.velocity.y = jump_force
	
	if stats.touching_physics && player._physshadow.grounded:
		stats.velocity.y *= 1.25
		return
	
	stats.velocity += stats.gravity * stats.gravity_modifier * 0.5 * delta
	
	stats.can_land = true
	
func has_space_above_head() -> bool:
	return !player.test_move(player.global_transform.translated(Vector3.UP * 0.1), Vector3.ZERO)

func queue_jump() -> void:
	var is_grounded: bool = player.is_grounded()
	
	if !is_grounded:
		queued_jump = true
		stats.can_land = false
		await Main.wait(Game.settings.jump_buffer)
		if queued_jump:
			queued_jump = false
			stats.can_land = true
	elif is_grounded:
		queued_jump = true
