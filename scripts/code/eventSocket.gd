extends Node

@export var head : RigidBody3D
@export var leftEye : MeshInstance2D
@export var rightEye : MeshInstance2D
@export var mouth : Node2D
@export var brb : Node2D
@export var starting : Node2D

func _ready():
	SignalBus.connect("websocketMessage", wsMessage)
	SignalBus.connect("faceColorChanged", changeFaceColor)

func wsMessage(message : Dictionary) -> void:
	if message["to"] == "avatar":
		match message["payload"]["command"]:
			"freeze_unfreeze_head":
				head.frozen = !head.frozen
			"reset_head":
				resetTv()
			"change_color":
				changeFaceColor(message["payload"]["data"])

func resetTv() -> void:
	head.rotation = Vector3(0, 0, 0)
	changeFaceColor("4e6fff")
	rightEye.position = head.origin_right_eye_position
	rightEye.scale = head.origin_right_eye_scale
	leftEye.position = head.origin_left_eye_postion
	leftEye.scale = head.origin_left_eye_scale

func changeFaceColor(couleur : Color) -> void:
	mouth.changeColor(couleur)
	rightEye.modulate = couleur
	leftEye.modulate = couleur
