extends Node2D

var size : Vector2 = Vector2.ZERO
var shape : PackedVector2Array = []

func _ready() -> void:
	updateSpecs()

func updateSpecs() -> void:
	var clickShape = get_node("clickShape")
	if clickShape != null && clickShape.is_class("CollisionPolygon2D"):
		shape = clickShape.polygon.duplicate()
		for i in shape.size():
			shape[i] = shape[i] + position

	match self.get_class():
		"Sprite2D":
			size = self.texture.get_size()
			size *= self.scale
		"Node2D":
			match get_child(0).get_class():
				"PanelContainer":#recommend a panelContainer
					size = get_child(0).get_rect().size
				"Node2D":
					size = get_child(0).getSize()
		#TODO Implement new support here

	get_parent().setSpecs(
		{
			"size": size,
			"shape": shape
		}
	)
