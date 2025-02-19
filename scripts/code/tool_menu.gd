extends PanelContainer

@export var noteContent : TextEdit
@export var imageLink : LineEdit
@export var videoLink : LineEdit
@export var animSelect : OptionButton
@export var messageList : VBoxContainer
@export var contentWindowScene : PackedScene
@export var httpImage : HTTPRequest
@export var httpVideo : HTTPRequest

func _ready() -> void:
	SignalBus.connect("createNewMessageListComponent", newMessageInList)
	httpImage.request_completed.connect(_on_request_completed_image)
	httpVideo.request_completed.connect(_on_request_completed_video)

func _on_request_completed_image(result, response_code, headers, body) -> void:
	print(response_code)
	if response_code == 200:
		var img = Image.new()
		var err = img.load_jpg_from_buffer(body)
		if validateImage(err, img): return 
		err = img.load_svg_from_buffer(body)
		if validateImage(err, img): return
		err = img.load_webp_from_buffer(body)
		if validateImage(err, img): return

func _on_request_completed_video(result, response_code, headers, body) -> void:
	if response_code == 200:
		var newNote = contentWindowScene.instantiate()
		newNote.setContent(
			{
				"type": "video",
				"content": httpVideo.download_file
			}
		)
		SignalBus.createOverlayElement.emit(newNote, true, Vector2(0, 0))

func validateImage(error : Error, image : Image) -> bool:
	if error == OK:
		var img_texture : ImageTexture = ImageTexture.create_from_image(image)
		var newNote = contentWindowScene.instantiate()
		newNote.setContent(
			{
				"type": "image",
				"content": img_texture
			}
		)
		SignalBus.createOverlayElement.emit(newNote, true, Vector2(0, 0))
		return true
	return false

func newMessageInList(message) -> void:
	messageList.add_child(message)
	messageList.move_child(message, 0)

func _on_anim_item_selected(index: int) -> void:
	var animName : String = animSelect.get_item_text(index)
	SignalBus.animationChange.emit(animName)

func _on_note_button_pressed() -> void:
	if noteContent.text.is_empty(): return
	var newNote = contentWindowScene.instantiate()
	newNote.setContent(
		{
			"type": "text",
			"content" : noteContent.text
		}
	)
	SignalBus.createOverlayElement.emit(newNote)

func _on_image_button_pressed() -> void:
	if imageLink.text.is_empty(): return
	httpImage.request(imageLink.text)

func _on_clear_windows_pressed() -> void:
	SignalBus.clearOverlayElements.emit()

func _on_window_enable_toggled(toggled_on: bool) -> void:
	SignalBus.OverlayElementsEnabled.emit(toggled_on)

func _on_joel_emote_enable_toggled(toggled_on: bool) -> void:
	SignalBus.EmoteJoelsEnabled.emit(toggled_on)

func _on_face_color_color_changed(color: Color) -> void:
	SignalBus.faceColorChanged.emit(color)

func _on_minimum_size_changed() -> void:
	get_parent().updateSpecs()

func _on_video_pressed() -> void:
	if videoLink.text.is_empty(): return
	httpVideo.request(videoLink.text)
