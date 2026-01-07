extends Control
class_name ExplainerFootnote

func set_custom_text(footnote_name: String, desc: String) -> void:
	%Name.visible = !footnote_name.is_empty()
	
	%Name.text = footnote_name
	%Desc.text = desc
