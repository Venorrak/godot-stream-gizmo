extends Node2D

var effect 

@onready
var spectrum = AudioServer.get_bus_effect_instance(1,0)
 
@onready
var topRightArray = $right.get_children()
 
@onready
var topLeftArray = $left.get_children()

@onready
var bottomRightArray = $right2.get_children()

@onready
var bottomLeftArray = $left2.get_children()

@onready
var audioPlayer = $AudioStreamPlayer
 
const VU_COUNT = 16
const HEIGHT = 150
const FREQ_MAX = 11050.0
 
const MIN_DB = 60

var allChildren : Array = []
 
# Called when the node enters the scene tree for the first time.
func _ready():
	audioPlayer.autoplay = true
	audioPlayer.playing = true
	allChildren += $right.get_children()
	allChildren += $left.get_children()
	allChildren += $right2.get_children()
	allChildren += $left2.get_children()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var prev_hz = 0
	for i in range(1,VU_COUNT+1):   
		var hz = i * FREQ_MAX / VU_COUNT;
		var f = spectrum.get_magnitude_for_frequency_range(prev_hz,hz)
		var energy = clamp((MIN_DB + linear_to_db(f.length()))/MIN_DB,0,1)
		var height = energy * HEIGHT
 
		prev_hz = hz
 
		var topRightRect = topRightArray[i - 1]
 
		var topLeftRect = topLeftArray[i - 1]
		
		var bottomRightRect = bottomRightArray[i - 1]
		
		var bottomLeftRect = bottomLeftArray[i - 1]
 
		var tween = get_tree().create_tween()
 
		tween.tween_property(topRightRect, "size", Vector2(topRightRect.size.x, height), 0.05)
 
		tween.tween_property(topLeftRect, "size", Vector2(topLeftRect.size.x, height), 0.05)
		
		tween.tween_property(bottomRightRect, "size", Vector2(bottomRightRect.size.x, height), 0.05)
		
		tween.tween_property(bottomLeftRect, "size", Vector2(bottomLeftRect.size.x, height), 0.05)

func changeColor(newColor : Color) -> void:
	for i in len(allChildren):
		allChildren[i].color = newColor
