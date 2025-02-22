extends Node2D

@export var timeLabel : RichTextLabel
@export var followLabel : RichTextLabel
@export var songLabel : RichTextLabel

func _ready():
	SignalBus.connect("websocketMessage", wsMessage)

func createLabelText(text : String) -> String:
	text = LabelBuilder.center(text)
	text = LabelBuilder.color(text, Color.BLACK)
	text = LabelBuilder.fontSize(text, 18)
	return text

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
