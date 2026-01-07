extends PlayerBehavior
class_name DebugBehavior

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet

@export var debug_window: Control
var prio: int = 0

func physics_update(delta: float) -> void:
	if !Game.settings.show_debug:
		return
	
	DebugDraw2D.custom_canvas = debug_window
	
	prio = 0
	
	DebugDraw2D.begin_text_group("DEBUG", 0, Color.WHITE, true, 15, 15)
	debug("FPS", Engine.get_frames_per_second())
	debug("STATE", player.get_current_state().name)
	debug("CROUCHED", stats.is_crouched)
	debug("VEL", "%3.2v" % stats.velocity)
	debug("PHYSVEL", "%3.2v" % player._physshadow.linear_velocity)
	debug("SPEED", "%3.2f" % stats.velocity.length())
	debug("WISHDIR", "%3.2v" % stats.wish_dir)
	debug("WISHSPD", stats.wish_speed)
	debug("HOLDING", stats.is_holding)
	debug("HOLDOBJ", str(stats.held_object.name) if stats.held_object != null else "null")
	debug("TOUCHINGPHYS", stats.touching_physics)
	debug("GROUNDED", player._physshadow.grounded)
	debug("PHYSGROUNDED", player._physshadow.physgrounded)
	debug("CONTACTS", player._physshadow.contacts)
	DebugDraw2D.end_text_group()
	
func debug(title: String, value: Variant, priority: int = 0) -> void:
	DebugDraw2D.set_text(title, value, prio)
	prio += 1
