extends Trinket
class_name TrinketSumpterIdol

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet = player.stats

@export var horse_neigh: AudioStream
@export var max_cooldown: float = 1.0
@export var cooldown: float = 0.0

func can_use() -> bool:
	return cooldown <= 0.0

func update(delta: float) -> void:
	if cooldown > 0.0:
		cooldown -= delta

func execute() -> void:
	SignalBus.sound_play_on_ui.emit(horse_neigh, 0.0, randf_range(0.8,1.0))
	cooldown = max_cooldown
