# meta-name: Player Trinket
# meta-description: Base template for trinkets
# meta-default: true
# meta-space-indent: 4

extends Trinket

# @onready var player: Player = self.owner
# @onready var stats: PlayerStatSheet = player.stats

func init() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func update_physics(delta: float) -> void:
	pass
	
func can_use() -> bool:
	return true

func execute() -> void:
	pass
	
func on_equip() -> void:
	pass
	
func on_unequip() -> void:
	pass

func do_stats_premove(_stats: PlayerStatSheet) -> void:
	pass

func do_stats_postmove(_stats: PlayerStatSheet) -> void:
	pass
