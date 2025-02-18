extends Control

@export var animMenu : PopupMenu

func _on_animations_index_pressed(index):
	var name : String = animMenu.get_item_text(index)
	SignalBus.animationChange.emit(name)
