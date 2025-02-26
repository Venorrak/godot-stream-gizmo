extends Node3D

@export var http : HTTPRequest
@export var albumCover : Sprite3D
@export var titleLabel : Label
@export var artistLabel : Label
@export var anim : AnimationPlayer

func _ready() -> void:
	SignalBus.connect("websocketMessage", wsMessage)
	http.request_completed.connect(_on_request_completed)
	
func wsMessage(message : Dictionary) -> void:
	if message["to"] == "spotifyOverlay" && message["from"] == 'spotify':
		var payload : Dictionary = message["payload"]
		if payload["type"] == 'song':
			titleLabel.text = payload["name"]
			artistLabel.text = payload["artist"]
			http.request(payload["image"])
	
func _on_request_completed(result, response_code, headers, body) -> void:
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
		var img_texture : ImageTexture = ImageTexture.create_from_image(image)
		albumCover.texture = img_texture
		anim.play("funny turn")
		return true
	return false
