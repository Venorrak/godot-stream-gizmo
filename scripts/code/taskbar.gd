extends Node2D
# Time
# CPU
# GPU
# RAM
# last Follow
# current Song
@export var containerHome : Control
@export var shaderTimer : Timer
var shaderMaterial : ShaderMaterial

@export var timePanel : Panel
@export var followPanel : Panel
@export var songPanel : Panel

@export var timeLabel : RichTextLabel
@export var followLabel : RichTextLabel
@export var songLabel : RichTextLabel

@export var containerSeparation : int = 25

var statsThread : Thread

func _ready():
	SignalBus.connect("websocketMessage", wsMessage)
	shaderMaterial = $ColorRect.material

func _physics_process(delta):
	updateContainerSize()
	updateShader()

func updateShader() -> void:
	shaderMaterial.set("shader_parameter/time", shaderTimer.time_left / 10)

func createLabelText(text : String) -> String:
	text = LabelBuilder.center(text)
	text = LabelBuilder.color(text, Color.BLACK)
	text = LabelBuilder.fontSize(text, 18)
	return text

func updateContainerSize() -> void:
	var containers : Array = containerHome.get_children()
	for i in len(containers):
		var thisTextLabel = containers[i].get_child(0)
		if thisTextLabel.get_line_count() > 1:
			thisTextLabel.size.x = 1000000
		var width : float = thisTextLabel.get_content_width()
		containers[i].size.x = width
		thisTextLabel.size.x = width
		if i < len(containers) - 1:
			var startPositionOfNextContainer : float = containers[i].position.x + containers[i].size.x + containerSeparation
			containers[i + 1].position.x = startPositionOfNextContainer

func wsMessage(data : Dictionary) -> void:
	if data["to"] == "avatar" and data["payload"]["command"] == "last_follow_update":
		var followerName = data["payload"]["data"]["name"]
		followerName = createLabelText("Last Follow : " + followerName)
		followLabel.text = followerName
	if data["to"] == "spotifyOverlay" and data["payload"]["type"] == "song":
		var songText = "Current Song : " + data["payload"]["name"] + " - " + data["payload"]["artist"]
		songText = createLabelText(songText)
		songLabel.text = songText

func _on_time_fetch_timeout():
	var myTime = Time.get_datetime_dict_from_system()
	var prettyHour = myTime["hour"]
	var prettyMinute = myTime["minute"]
	if prettyHour < 10:
		prettyHour = "0" + str(prettyHour)
	else:
		prettyHour = str(prettyHour)
		
	if prettyMinute < 10:
		prettyMinute = "0" + str(prettyMinute)
	else:
		prettyMinute = str(prettyMinute)
		
	var TimeString = prettyHour + ":" + prettyMinute
	TimeString = createLabelText(TimeString)
	timeLabel.text = TimeString
