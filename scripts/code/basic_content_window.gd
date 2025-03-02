extends Node2D
var size : Vector2 = Vector2.ZERO

@export var maxWidthImage : int
@export var maxHeightImage : int
@export var drawingBoardScene : PackedScene

var currentVideoPlayer : VideoStreamPlayer

func getSize() -> Vector2:
	return size

func setContent(content : Dictionary) -> void:
	#{
		#"type": "image", # "video", "text"
		#"content": "allo"
	#}
	match content["type"]:
		"image":
			var newImage : Sprite2D = Sprite2D.new()
			newImage.texture = content["content"]
			add_child(newImage)
		"video":
			var newContainer : PanelContainer = PanelContainer.new()
			var newListContainer : VBoxContainer = VBoxContainer.new()
			var newSlider : HSlider = HSlider.new()
			var newVideoPlayer : VideoStreamPlayer = VideoStreamPlayer.new()
			var newFFMPEG : FFmpegVideoStream = FFmpegVideoStream.new()
			newSlider.max_value = 1.0
			newSlider.step = 0.01
			newSlider.value = 0.1
			newSlider.set("theme_override_icons/grabber", load("res://7tv/Joel.png"))
			newSlider.value_changed.connect(volumeChanged)
			newFFMPEG.file = "temp.mp4"
			newVideoPlayer.autoplay = true
			newVideoPlayer.loop = true
			newVideoPlayer.stream = newFFMPEG
			currentVideoPlayer = newVideoPlayer
			add_child(newContainer)
			newContainer.add_child(newListContainer)
			newListContainer.add_child(newVideoPlayer)
			newListContainer.add_child(newSlider)
		"text":
			var newContainer : PanelContainer = PanelContainer.new()
			newContainer.connect("resized", panelSizeUpdated)
			var newLabel : RichTextLabel = RichTextLabel.new()
			newLabel.custom_minimum_size = Vector2(130, 0)
			newLabel.bbcode_enabled = true
			newLabel.fit_content = true
			newLabel.scroll_active = false
			newLabel.autowrap_mode = TextServer.AUTOWRAP_OFF
			newLabel.text = content["content"]
			add_child(newContainer)
			newContainer.add_child(newLabel)
		"draw":
			var newDrawing = drawingBoardScene.instantiate()
			newDrawing.setPanelSize(content["content"])
			add_child(newDrawing)
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
			size = get_child(0).size
			var videostream = get_child(0).get_child(0).get_child(0)
			if videostream != null && videostream.is_class("VideoStreamPlayer"):
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

func panelSizeUpdated() -> void:
	size = get_child(0).size
	get_parent().updateSpecs()

func volumeChanged(newVolume : float) -> void:
	currentVideoPlayer.volume = newVolume
