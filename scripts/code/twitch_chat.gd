extends Node2D

@export var messageSeperation : int
@export var chatMessageScene : PackedScene
@export var scrollSpeed : float

var messages : Array = []
var loadingMessages : Array = []
var scrolling : bool = false
var scrollingAmount : float = 0

func _ready():
	SignalBus.connect("websocketMessage", wsMessage)

func _physics_process(delta):
	if messages.size()> 30:
		messages.remove_at(29)
	
	if scrolling:
		for i in messages.size():
			messages[i]["content"].position.y = lerpf(messages[i]["content"].position.y, (messages[i]["lastPosition"].y + scrollingAmount), scrollSpeed)
		if is_equal_approx(messages[0]["content"].position.y, messages[0]["lastPosition"].y + scrollingAmount):
			for i in messages.size():
				messages[i]["lastPosition"] = messages[i]["content"].position
			scrolling = false
			finishMessage()
	
	if loadingMessages.size() > 0 and scrolling == false and loadingMessages[0].rendered == true:
		var loadedMessageHeight = loadingMessages[0].getMessageHeight()
		loadingMessages[0].anim.play("enterScene")
		if messages.size() > 0:
			scrolling = true
			scrollingAmount = loadedMessageHeight + messageSeperation
		else:
			finishMessage()

func wsMessage(data : Dictionary) -> void:
	if data["to"] == "chat":
		var payload : Dictionary = data["payload"]
		var newMessage = chatMessageScene.instantiate()
		newMessage.passVariables(payload["name"], Color(payload["name_color"]), payload["message"], payload["lore_score"], payload["profile_image_url"], payload["type"])
		newMessage.position = Vector2(1920, messageSeperation)
		loadingMessages.append(newMessage)
		add_child(newMessage)
		
func finishMessage() -> void:
	messages.push_front({"content": loadingMessages[0], "lastPosition": loadingMessages[0].position})
	loadingMessages.remove_at(0)
