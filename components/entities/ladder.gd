extends Area3D
class_name Ladder

@export var normal_empty: Node3D
@export var normal: Vector3
@export var max_y: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if normal_empty:
		normal = normal_empty.global_basis.y
		max_y = normal_empty.global_position.y
	
	connect("body_entered", body_entered)
	connect("body_exited", body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#DebugDraw3D.draw_line(global_position, global_position + normal, Color.RED)

func body_entered(body: Node3D) -> void:
	if body is Player:
		var player: Player = body
		player.stats.current_ladder = self
		player.set_state("PlayerClimbingState")
	
func body_exited(body: Node3D) -> void:
	if body is Player:
		var player: Player = body
		if player.stats.current_ladder == self:
			player.stats.current_ladder = null
			
		if player.get_current_state() is PlayerClimbingState:
			player.set_state("PlayerFallingState")
			
		if absf(player.global_position.y - max_y) < 0.3:
			player.stats.velocity.y = 0
			player.stats.velocity += -normal * 5.0
