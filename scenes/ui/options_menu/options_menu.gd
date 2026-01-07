extends CenterContainer
class_name UIOptionsMenu

@export var current_tab: UIOptionsMenuTab
@export var current_tab_panel: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for tab: UIOptionsMenuTab in self.find_children("*", "UIOptionsMenuTab") as Array[UIOptionsMenuTab]:
		tab.wants_select.connect(process_select)
		tab.set_unselected()
		
	process_select(current_tab)

func process_select(tab: UIOptionsMenuTab) -> void:
	current_tab.set_unselected()
	
	current_tab = tab
	current_tab.set_selected()
