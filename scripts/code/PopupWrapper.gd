extends Window


# Called when the node enters the scene tree for the first time.
func _ready():
	set_current_screen(0)
	move_to_center()

func updateSize() -> void:
	var newSize : Vector2 = get_contents_minimum_size()
	size = newSize + Vector2(100, 100)

func setContent(something) -> void:
	add_child(something)
	updateSize()

func setTitle(newTitle : String) -> void:
	title = newTitle

func setPosition(newPosition : Vector2) -> void:
	position = newPosition

func _on_close_requested():
	#self.queue_free()
	pass
