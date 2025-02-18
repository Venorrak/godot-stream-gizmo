extends RigidBody3D

@export_range(0.0, 1.0, 0.05) var rotationSpeed : float

@export var starting: bool = false
@export var starting_screen : Node2D
@export var brb: bool = false
@export var brb_screen : Node2D

var frozen: bool = false

@export var left_eye : MeshInstance2D
var origin_left_eye_postion = 0
var origin_left_eye_scale = 0

@export var right_eye : MeshInstance2D
var origin_right_eye_position = 0
var origin_right_eye_scale = 0

var targetRotation : Vector3
		
# Called when the node enters the scene tree for the first time.
func _ready():
	origin_left_eye_postion = left_eye.position
	origin_left_eye_scale = left_eye.scale
	origin_right_eye_position = right_eye.position
	origin_right_eye_scale = right_eye.scale
	$movementSocket.connect("messageReceived", updateTV)
	targetRotation = rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	starting_screen.visible = starting
	brb_screen.visible = brb
	
	if frozen == false:
		rotation.y = lerp(rotation.y, targetRotation.y, rotationSpeed)
		rotation.z = lerp(rotation.z, targetRotation.z, rotationSpeed)
	

func updateTV(pkt) -> void:
	var left_face_pos = pkt[0]
	var right_face_pos = pkt[1]
	var top_face_pos = pkt[2]
	var bottom_face_pos = pkt[3]
	
	var top_left_eye_pos = pkt[4]
	var bottom_left_eye_pos = pkt[5]
	var iris_left_eye_pos = pkt[6]
	var left_left_eye_pos = pkt[7]
	var right_left_eye_pos = pkt[8]
	
	var top_right_eye_pos = pkt[9]
	var bottom_right_eye_pos = pkt[10]
	var iris_right_eye_pos = pkt[11]
	var left_right_eye_pos = pkt[12]
	var right_right_eye_pos = pkt[13]
	
	targetRotation.y = ((left_face_pos[2] - right_face_pos[2]) / 180)
	targetRotation.z = (((top_face_pos[2] - bottom_face_pos[2]) / 150) + 0.5)
		
		
	var delta_opening_right_eye = sqrt(pow(top_right_eye_pos[0] - bottom_right_eye_pos[0], 2) + pow(top_right_eye_pos[1] - bottom_right_eye_pos[1], 2) + pow(top_right_eye_pos[2] - bottom_right_eye_pos[2], 2))
	var delta_opening_left_eye = sqrt(pow(top_left_eye_pos[0] - bottom_left_eye_pos[0], 2) + pow(top_left_eye_pos[1] - bottom_left_eye_pos[1], 2) + pow(top_left_eye_pos[2] - bottom_left_eye_pos[2], 2))
	if frozen == false:
		if delta_opening_right_eye < 10.6:
			right_eye.scale.y = 20
		else:
			right_eye.scale.y = origin_right_eye_scale.y
			
		if delta_opening_left_eye < 10.6:
			left_eye.scale.y = 20
		else:
			left_eye.scale.y = origin_left_eye_scale.y
		
	var left_left_eye_delta = sqrt(pow(left_left_eye_pos[0] - iris_left_eye_pos[0], 2) + pow(left_left_eye_pos[1] - iris_left_eye_pos[1], 2) + pow(left_left_eye_pos[2] - iris_left_eye_pos[2], 2)) 
	var right_left_eye_delta = sqrt(pow(right_left_eye_pos[0] - iris_left_eye_pos[0], 2) + pow(right_left_eye_pos[1] - iris_left_eye_pos[1], 2) + pow(right_left_eye_pos[2] - iris_left_eye_pos[2], 2))
	var left_right_eye_delta = sqrt(pow(left_right_eye_pos[0] - iris_right_eye_pos[0], 2) + pow(left_right_eye_pos[1] - iris_right_eye_pos[1], 2) + pow(left_right_eye_pos[2] - iris_right_eye_pos[2], 2))
	var right_right_eye_delta = sqrt(pow(right_right_eye_pos[0] - iris_right_eye_pos[0], 2) + pow(right_right_eye_pos[1] - iris_right_eye_pos[1], 2) + pow(right_right_eye_pos[2] - iris_right_eye_pos[2], 2))
	
	if frozen == false:
		left_eye.position.x = origin_left_eye_postion.x + (-left_left_eye_delta + right_left_eye_delta) * 7
		right_eye.position.x = origin_right_eye_position.x + (-left_right_eye_delta + right_left_eye_delta) * 7
	
