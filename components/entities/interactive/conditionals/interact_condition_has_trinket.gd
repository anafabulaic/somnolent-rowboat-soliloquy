extends InteractCondition
class_name InteractionConditionHasTrinket

@export var trinket: TrinketReference

## Should the trinket be equipped?
@export var equipped: bool = true

func condition() -> bool:
	if equipped:
		return Game.trinkets.has_trinket(trinket) and Game.trinkets.is_trinket_equipped(trinket)
	else:
		return Game.trinkets.has_trinket(trinket)
