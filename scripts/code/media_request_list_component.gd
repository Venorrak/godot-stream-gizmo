extends HBoxContainer

@export var imageNode : TextureRect
@export var http : HTTPRequest
@export var contentWindowScene : PackedScene

var imageUrl : String = ""
var imageTextur : ImageTexture

func _ready() -> void:
	http.request(imageUrl)

func _on_button_pressed() -> void:
	var newNote = contentWindowScene.instantiate()
	newNote.setContent(
		{
			"type": "image",
			"content": imageTextur
		}
	)
	SignalBus.createOverlayElement.emit(newNote, true, Vector2(0, 0))
	
func setUrl(url : String) -> void:
	imageUrl = url

func _on_image_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var img = Image.new()
		var err = img.load_jpg_from_buffer(body)
		if validateImage(err, img): return 
		err = img.load_svg_from_buffer(body)
		if validateImage(err, img): return
		err = img.load_webp_from_buffer(body)
		if validateImage(err, img): return
	
func validateImage(error : Error, image : Image) -> bool:
	if error == OK:
		imageTextur = ImageTexture.create_from_image(image)
		imageNode.texture = imageTextur
		return true
	return false
