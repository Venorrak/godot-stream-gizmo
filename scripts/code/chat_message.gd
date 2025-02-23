extends PanelContainer
@export var baseBorderColor : Color = Color.BLACK
@export var glowSpeed : float = 1

@export_category("ref")
@export var http : HTTPRequest
@export var nameLabel : RichTextLabel
@export var messageLabel : RichTextLabel
@export var glowTimer : Timer

@export_category("audio")
@export var messageSound : AudioStream
@export var notifSound : AudioStream
@export var subscribeSound : AudioStream
@export var raidSound : AudioStream
@export var cheerSound : AudioStream

var id : int = -1
var username : String = " unknown"
var nameColor : Color = Color.WHITE
var message : Array = [{"type": "text", "content": "blank"}]
var lore : float = 0.0
var pfpUrl : String = ""
var messageType : String = "default"

var glowingColor : Color = Color.BLACK
var panelTheme : StyleBoxFlat
var glowState : bool = false

var registeredImages : Dictionary = {}
var imageLoadQueue : Array = []
var currentRequest : String = ""

var emotesList : Array = []

var rendered : bool = false

func setContent(data : Dictionary) -> void:
	username = " " + data["name"]
	nameColor = Color(data["name_color"])
	message = data["message"].duplicate(true)
	lore = data["lore_score"]
	pfpUrl = data["profile_image_url"]
	messageType = data["type"]
	id = data["id"]
	getEmotes()
	imageLoadQueue.append(pfpUrl)
	for i in len(message):
		if message[i]["type"] == "emote" and not imageLoadQueue.has("https://static-cdn.jtvnw.net/emoticons/v2/" + str(message[i]["id"]) + "/static/light/1.0"):
			imageLoadQueue.append("https://static-cdn.jtvnw.net/emoticons/v2/" + str(message[i]["id"]) + "/static/light/1.0")
		if message[i]["type"] == "text":
			var tempText : String = message[i]["content"]
			message[i]["content"] = treatForEmotes(tempText)

func _physics_process(delta):
	var state : float = glowTimer.time_left / glowSpeed
	if glowState:
		panelTheme.border_color = baseBorderColor.lerp(glowingColor, state)
	else:
		panelTheme.border_color = glowingColor.lerp(baseBorderColor, state)

func _ready():
	panelTheme = self.get("theme_override_styles/panel") as StyleBoxFlat
	glowTimer.start(glowSpeed)
	match messageType:
		"notif":
			glowingColor = Color.YELLOW
		"subscribe":
			glowingColor = Color.GREEN
		"raid":
			glowingColor = Color.BLUE
		"cheer":
			glowingColor = Color.PURPLE
	
	http.request_completed.connect(_on_request_completed)
	if imageLoadQueue.size() > 0:
		currentRequest = imageLoadQueue[0]
		http.request(currentRequest)
	else:
		onLoadFinished()

func treatForEmotes(thisText : String) -> Array:
	var newContent : Array = thisText.split(" ")
	for emoteNb in emotesList.size():
		for partNb in newContent.size():
			if is_same(emotesList[emoteNb], newContent[partNb]):
			#if emotesList[emoteNb] == newContent[partNb]:
				var newImg : Image = Image.new()
				newImg.load("res://7tv/" + emotesList[emoteNb] + ".png")
				newContent[partNb] = ImageTexture.create_from_image(newImg)
	return newContent

func getEmotes() -> void:
	emotesList = DirAccess.get_files_at("7tv")
	var futureList : Array = []
	for emote in emotesList:
		if emote.get_extension() == 'png':
			futureList.append(emote.trim_suffix(".png"))
	emotesList = futureList
	
func _on_request_completed(result, response_code, headers, body) -> void:
	imageLoadQueue.erase(currentRequest)
	if response_code == 200:
		var img = Image.new()
		var err = img.load_png_from_buffer(body)
		if err == OK:
			var img_texture : ImageTexture = ImageTexture.create_from_image(img)
			registeredImages[currentRequest] = img_texture
	if imageLoadQueue.size() == 0:
		onLoadFinished()
	else:
		currentRequest = imageLoadQueue[0]
		http.request(currentRequest)
	
func onLoadFinished() -> void:
	setNameLabelContent()
	setMessageLabelContent()
	makeSound()
	rendered = true
	
func treatForNameLabel(name : String, color : Color) -> String:
	var text : String = name
	text = LabelBuilder.fontSize(text, 19)
	text = LabelBuilder.color(text, color)
	return text
	
func setNameLabelContent() -> void:
	nameLabel.append_text("[center]")
	if pfpUrl != "":
		nameLabel.add_image(registeredImages[pfpUrl], 30, 30)
	nameLabel.append_text(treatForNameLabel(username, nameColor))

func setMessageLabelContent() -> void:
	messageLabel.append_text("[center]")
	for i in len(message):
		match message[i]["type"]:
			"emote":
				var emoteUrl : String = "https://static-cdn.jtvnw.net/emoticons/v2/" + message[i]["id"] + "/static/light/1.0"
				messageLabel.add_image(registeredImages[emoteUrl], 40, 40, Color(1, 1, 1, 1))
				SignalBus.createJoel.emit(1, registeredImages[emoteUrl])
			"text":
				messageLabel.append_text("[color=" + str(Color.WHITE.lerp(Color.GREEN, lore).to_html(false)) + "][font_size=" + str(19) + "]")
				for part in message[i]["content"]:
					if typeof(part) == TYPE_STRING:
						messageLabel.append_text(part + " ")
					else:
						messageLabel.add_image(part, 40, 40, Color(1, 1, 1, 1))
						SignalBus.createJoel.emit(1, part)

func _on_glow_timeout():
	glowState = !glowState

func makeSound() -> void:
	match messageType:
		"default":
			AudioManager.playSound(messageSound, 0.1)
		"notif":
			AudioManager.playSound(notifSound, 0.5)
		"subscribe":
			AudioManager.playSound(subscribeSound, 0.5)
		"raid":
			AudioManager.playSound(raidSound, 0.5)
		"cheer":
			AudioManager.playSound(cheerSound, 0.5)

#func _exit_tree() -> void:
	#ChatHandler.restoreMessage(id)

func _on_minimum_size_changed() -> void:
	get_parent().updateSpecs()
