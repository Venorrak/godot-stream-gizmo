extends Node2D

@export var timeLabel : RichTextLabel
@export var followLabel : RichTextLabel
@export var songLabel : RichTextLabel
@export var JCPChartParent : HBoxContainer
@export var http : HTTPRequest

var json : JSON = JSON.new()
var JCPs : Array = []

func _ready():
	SignalBus.connect("websocketMessage", wsMessage)
	createChart()

func createChart() -> void:
	var originalBar : ProgressBar = JCPChartParent.get_child(0)
	for i in 59:
		JCPChartParent.add_child(originalBar.duplicate())

func createLabelText(text : String) -> String:
	text = LabelBuilder.center(text)
	text = LabelBuilder.color(text, Color.BLACK)
	text = LabelBuilder.fontSize(text, 28)
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

func _on_jc_prefresh_timeout() -> void:
	http.request("https://server.venorrak.dev/api/joels/JCP/short?limit=60")

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var pkt = json.parse_string(body.get_string_from_utf8())
		JCPs = []
		for i in pkt:
			JCPs.append(i["JCP"])
		castToChart()
		
func castToChart() -> void:
	var progresses : Array = JCPChartParent.get_children()
	for i in progresses.size():
		progresses[i].value = JCPs[i]
