extends HBoxContainer

@export var usernameLabel : Label
@export var messageLabel : Label

var id : int = -1
var username : String = ""
var message : String = ""

func _ready() -> void:
	usernameLabel.text = username
	messageLabel.text = message
	
func setContent(data : Dictionary) -> void:
	username = data["name"]
	id = data["id"]
	message = data["raw_message"]
	
func _on_button_pressed() -> void:
	ChatHandler.restoreMessage(id)
