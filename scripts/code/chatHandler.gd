extends Node
var messageScene = preload("res://scenes/window_types/chat_message_window.tscn")
var messageListScene = preload("res://scenes/message_list_component.tscn")
var messsages : Array = []

var index : int = 0

func _ready() -> void:
	SignalBus.connect("websocketMessage", wsMessage)
	
func wsMessage(message : Dictionary) -> void:
	if message["to"] == "chat":
		var payload : Dictionary = message["payload"]
		print(payload)
		payload["id"] = index
		index += 1
		messsages.append(payload)
		var newMessage = messageScene.instantiate()
		newMessage.setContent(payload)
		var newListMessage = messageListScene.instantiate()
		newListMessage.setContent(payload)
		SignalBus.createOverlayElement.emit(newMessage)
		SignalBus.createNewMessageListComponent.emit(newListMessage)

func restoreMessage(messageId : int) -> void:
	var rMessagePayload : Dictionary = {}
	for mes in messsages:
		if mes["id"] == messageId:
			rMessagePayload = mes
	if rMessagePayload != {}:
		var newMessage = messageScene.instantiate()
		newMessage.setContent(rMessagePayload)
		SignalBus.createOverlayElement.emit(newMessage)
