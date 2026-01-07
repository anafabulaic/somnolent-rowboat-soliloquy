## If we're using the Conditions Activate Children Exclusive mode, this functions as a catch-all else statement if none of the other conditions are true.
extends InteractCondition
class_name InteractConditionElse

func condition() -> bool:
	return true
