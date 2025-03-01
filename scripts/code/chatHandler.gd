extends Node
@export var messageScene : PackedScene
@export var messageListScene : PackedScene
@export var mediaRequestScene : PackedScene

@export var liveReaction : PackedScene

var messsages : Array = []

var index : int = 0
var CommandsRef : Dictionary = {
	"!commands": sendCommandsToChat,
	"!command": sendCommandsToChat,
	"!c": sendCommandsToChat,
	"!discord": sendDiscordToChat,
	
	"!image": createMediaRequest,
	"!livereaction": createLiveReaction,
	"!emotes": sendEmoteList,
	":3": playProdParticles
}

func _ready() -> void:
	SignalBus.connect("websocketMessage", wsMessage)
	
func wsMessage(message : Dictionary) -> void:
	if message["to"] == "chat":
		var payload : Dictionary = message["payload"]
		print(payload)
		if treatCommands(payload): return
		payload["id"] = index
		index += 1
		messsages.append(payload)
		var newListMessage = messageListScene.instantiate()
		newListMessage.setContent(payload)
		var newMessage = messageScene.instantiate()
		newMessage.setContent(payload)
		SignalBus.createNewMessageListComponent.emit(newListMessage)
		SignalBus.createOverlayElement.emit(newMessage, true, randomPositionInWindow())

func restoreMessage(messageId : int) -> void:
	var rMessagePayload : Dictionary = {}
	for mes in messsages:
		if mes["id"] == messageId:
			rMessagePayload = mes
	if rMessagePayload != {}:
		var newMessage = messageScene.instantiate()
		newMessage.setContent(rMessagePayload)
		SignalBus.createOverlayElement.emit(newMessage, true, randomPositionInWindow())

func treatCommands(data : Dictionary) -> bool:
	var words : PackedStringArray = data["raw_message"].split(" ")
	for command in CommandsRef.keys():
		if command == words[0].to_lower():
			CommandsRef[command].call(words)
			return true
	return false

func createLiveReaction(words : PackedStringArray) -> void:
	var newLiveReact = liveReaction.instantiate()
	SignalBus.createOverlayElement.emit(newLiveReact)
	
func createMediaRequest(words : PackedStringArray) -> void:
	if words[1] != null:
		var newMediaRequest = mediaRequestScene.instantiate()
		newMediaRequest.setUrl(words[1])
		SignalBus.createNewMessageListComponent.emit(newMediaRequest)

func randomPositionInWindow() -> Vector2:
	var rand_x : float = randf_range(0.0, 750.0)
	var rand_y : float = randf_range(0.0, 600.0)
	return Vector2(rand_x, rand_y)

func sendCommandsToChat(words : PackedStringArray) -> void:
	var data : Dictionary = {
		"action": "sendMessage",
		"content": "!discord, !song, !JoelCommands, !image url, !liveReaction"
	}
	SignalBus.sendMessageToBus.emit(data)

func sendDiscordToChat(words: PackedStringArray) -> void:
	var data : Dictionary = {
		"action": "sendMessage",
		"content": "You can see me talking on prod's discord server: https://discord.gg/JzPgeMp3EV or on Jake's discord server: https://discord.gg/MRjMmxQ6Wb"
	}
	SignalBus.sendMessageToBus.emit(data)

func sendEmoteList(words : PackedStringArray) -> void:
	var emotesList = DirAccess.get_files_at("7tv")
	var newList : Array = []
	for emote in emotesList:
		if emote.get_extension() == 'png':
			newList.append(emote.trim_suffix(".png"))
	var data : Dictionary = {
		"action": "sendMessage",
		"content": str(newList)
	}
	SignalBus.sendMessageToBus.emit(data)

func playProdParticles (words : PackedStringArray) -> void:
	SignalBus.playProdParticles.emit()
