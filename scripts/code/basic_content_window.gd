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
			var newContainer : PanelContainer = PanelContainer.new()
			var newVideoPlayer : VideoStreamPlayer = VideoStreamPlayer.new()
			var newFFMPEG : FFmpegVideoStream = FFmpegVideoStream.new()
			newFFMPEG.file = "temp.mp4"
			newVideoPlayer.autoplay = true
			newVideoPlayer.loop = true
			newVideoPlayer.stream = newFFMPEG
			add_child(newContainer)
			newContainer.add_child(newVideoPlayer)
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
			get_child(0).scale = Vector2(newScale, newScale)
			get_child(0).position += (size * newScale)/2
			size *= newScale
		"PanelContainer":
			size = get_child(0).get_rect().size
			if get_child(0).get_child(0).is_class("VideoStreamPlayer"):
				var scaleToTargetWidth : float = maxWidthImage / size.x
				var scaleToTargetHeight : float = maxHeightImage / size.y
				var newScale : float = 1
				if abs(1 - scaleToTargetWidth) < abs(1 - scaleToTargetHeight):
					newScale = scaleToTargetWidth
				else:
					newScale = scaleToTargetHeight
				get_child(0).scale = Vector2(newScale, newScale)
				size *= newScale
	get_parent().updateSpecs()
