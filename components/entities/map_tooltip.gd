extends Node
class_name MapToolTip

@export var text: String = "<empty>"
@export var duration: float = 3.0
@export var sound: AudioStream

# initial delay, affects all sibling MapTooltips simultaneously
@export var predelay: float = 0.0

# delay between multiple MapToolTips. does nothing if we're the first child
@export var delay: float = 0.0
var _delay: float = 0.0
var do_delay: bool = false

@export var cancellable: bool = false

func _ready() -> void:
	var parent: Node = self.get_parent()
	if parent is Area3D:
		var area_parent: Area3D = parent
		area_parent.body_entered.connect(do_enter_trigger, Object.ConnectFlags.CONNECT_ONE_SHOT)
		if cancellable: area_parent.body_exited.connect(do_exit_trigger, Object.ConnectFlags.CONNECT_ONE_SHOT)
		if !parent.has_meta("MetaTooltipValidated"):
			_validate_area3d_parent(area_parent)
	
	# if we're the first child, set up the delay counters of all other sibling MapTooltips.
	if !do_delay:
		var cumulative_delay: float = 0.0
		
		for child: MapToolTip in self.get_parent().find_children("*", "MapToolTip") as Array[MapToolTip]:
			child.do_delay = true
			
			if child == self:
				continue
			
			cumulative_delay += child.delay
			child._delay = cumulative_delay

func _validate_area3d_parent(parent: Area3D) -> void:
	parent.set_meta("MetaTooltipValidated", true)

	parent.collision_layer = 0
	parent.collision_mask = 0
	parent.set_collision_mask_value(32, true)

	parent.monitorable = false
	
func do_enter_trigger(body: Node3D) -> void:
	if predelay > 0.0:
		await Main.wait(predelay)
		
	if _delay > 0.0:
		await Main.wait(_delay)
		
	spawn_tooltip()
	
func do_exit_trigger(body: Node3D) -> void:
	SignalBus.ui_cancel_tooltip.emit(text)

func spawn_tooltip() -> void:
	if !sound:
		sound = System.sound.ui_tooltip_sound
	
	SignalBus.ui_do_tooltip.emit(text, duration, sound)
