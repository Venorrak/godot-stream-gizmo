extends RigidBody2D
@export var acceleration: Vector2 = Vector2(0,0)
@export var emoteSprite : Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	linear_velocity += acceleration
	acceleration *= 0
	look_at(position + linear_velocity)

func ApplyForce(force: Vector2):
	acceleration += force

func ApplyFriction(friction: float):
	acceleration *= friction

func setSpeed(vector: Vector2):
	linear_velocity = vector

func setScale(size: Vector2):
	$CollisionPolygon2D.scale = $CollisionPolygon2D.scale * size
	$Sprite2D.scale = $Sprite2D.scale * size

func _on_death_timer_timeout():
	queue_free()
	
func setMouthEmote(img : Texture2D) -> void:
	emoteSprite.texture = img
