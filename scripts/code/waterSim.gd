extends Node2D
var restLength: float = 0.0
var anchor: Vector2 = Vector2(0, 0)
@onready var endPoint = $Sprite2D
var endPointSpeed: Vector2 = Vector2(0, 0)
var endPointAcc: Vector2 = Vector2(0, 0)
@export var dampening: float = 0.01
@export var springStrength: float = 0.0001
@onready var springLine = $Line2D
@onready var maxLength: int = 500
@onready var collisionShape = $Sprite2D/collisionBody/CollisionShape2D
@export var waterCollisionDampening: float = 1 

# Called when the node enters the scene tree for the first time.
func _ready():
	waterCollisionDampening /= 1000
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var points = springLine.get_points()
	points[1] = endPoint.position
	springLine.set_points(points)
	
	
	var deltaY = endPoint.position.y - anchor.y
	var x = deltaY - restLength
	var loss = -dampening * endPointSpeed.y
	var force = -springStrength * x + loss
	applyForce(force)
	restainLength()
	
func applyForce(force: float):
	endPointSpeed.y += force
	endPoint.position += endPointSpeed

func restainLength():
	var distVec = endPoint.position - anchor
	var trueLength = getMag(distVec)
	if trueLength > maxLength:
		distVec = distVec.normalized()
		distVec *= maxLength

func getMag(vector: Vector2):
	return sqrt((vector.x * vector.x) + (vector.y * vector.y))

func setAnchor(_position: Vector2):
	var points = springLine.get_points()
	points[0] = _position
	springLine.set_points(points)
	anchor = _position

func setEndPosition(_position: Vector2):
	endPoint.position = _position

func getEndPosition():
	return endPoint.position

func setCollisionWidth(width: float):
	collisionShape.shape.size.x = width

func _on_collision_body_body_entered(body):
	var yVelocity = body.linear_velocity.y * waterCollisionDampening
	applyForce(yVelocity)
