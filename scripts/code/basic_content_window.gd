extends Node2D
var size : Vector2 = Vector2.ZERO

@export var maxWidthImage : int
@export var maxHeightImage : int

func getSize() -> Vector2:
	return size

func setContent(content : Dictionary) -> void:
	{
		"type": "image", # "video", "text"
		"content": "allo"
	}
	match content["type"]:
		"image":
			var newImage : Sprite2D = Sprite2D.new()
			newImage.texture = content["content"]
			add_child(newImage)
		"video":
			pass
		"text":
			var newContainer : PanelContainer = PanelContainer.new()
			var newLabel : Label = Label.new()
			newLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			newLabel.custom_minimum_size = Vector2(130, 0)
			newLabel.text = content["content"]
			add_child(newContainer)
			newContainer.add_child(newLabel)
	get_parent().updateSpecs()


func _on_child_entered_tree(node: Node) -> void:
	match get_child(0).get_class():
		"Sprite2D":
			size = get_child(0).texture.get_size()
			var scaleToTargetWidth : float = maxWidthImage / size.x
			var scaleToTargetHeight : float = maxHeightImage / size.y
			# x   max
			# - = ---
			# 1 = size
			var newScale : float = 1
			if abs(1 - scaleToTargetWidth) < abs(1 - scaleToTargetHeight):
				newScale = scaleToTargetWidth
			else:
				newScale = scaleToTargetHeight
			print(scaleToTargetHeight)
			print(scaleToTargetWidth)
			get_child(0).scale = Vector2(newScale, newScale)
			print(get_child(0).scale)
			get_child(0).position += (size * newScale)/2
			size *= newScale
		"PanelContainer":
			size = get_child(0).get_rect().size
	get_parent().updateSpecs()
