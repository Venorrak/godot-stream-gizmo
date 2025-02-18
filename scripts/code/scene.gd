extends Node3D

@export var head : RigidBody3D
@export var water : Node2D
@onready var animationStateMachine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback

func _ready():
	get_tree().get_root().set_transparent_background(true)
	SignalBus.connect("websocketMessage", wsEvent)
	SignalBus.connect("animationChange", animEvent)

func animEvent(animName : String) -> void:
	match animName:
		"brb":
			toBrb()
		"starting":
			toStarting()
		"zoom":
			toZoom()
		"back":
			toBack()

func wsEvent(data : Dictionary) -> void:
	if data["to"] == "avatar":
		match data["payload"]["command"]:
			"goToBrb":
				toBrb()
			"goToStarting":
				toStarting()
			"goToZoom":
				toZoom()
			"goToDefault":
				toBack()
			"Joel_Sent":
				createJoel(data)
					
func toBrb() -> void:
	head.frozen = true
	$Tv/eventSocket.resetTv()
	animationStateMachine.travel("brb_on")
	
func toStarting() -> void:
	head.frozen = true
	$Tv/eventSocket.resetTv()
	animationStateMachine.travel("start_on")
	
func toZoom() -> void:
	head.frozen = false
	if (animationStateMachine.get_current_node() == "start_on"):
		animationStateMachine.travel("start_off")
	elif (animationStateMachine.get_current_node() == "brb_on"):
		animationStateMachine.travel("brb_off")
	else:
		animationStateMachine.travel("zoom_in")
		
func toBack() -> void:
	head.frozen = false
	animationStateMachine.travel("zoom_out")
	
func createJoel(data : Dictionary) -> void:
	var newJoel = Sprite2D.new()
	if "size" in data["payload"]["params"]:
		water.spawnJoel(data["payload"]["params"]["size"])
	else:
		water.spawnJoel()
