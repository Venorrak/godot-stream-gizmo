extends Node

@onready var _MainWindow: Window = get_window()
@onready var _MainScreen: int = _MainWindow.current_screen

@export var spawnedOnStart : Array[PackedScene]
@export var view_window: PackedScene
@export var sceneRoot : Node2D #contains the scene only visible in the floating windows
@export var killArea : Area2D

@export var attractionSpeed : float

var world_offset: = Vector2i.ZERO
var attractedObjects : Array = []
var windowCanAppear : bool = true
var windows : Array = []

func _ready() -> void:
	#_MainWindow.set_canvas_cull_mask_bit(1, false) #make sceneRoot invisibe on main window
	_MainWindow.set_canvas_cull_mask_bit(2, false)
	world_offset = DisplayServer.screen_get_size(1) #TODO change this world offset in case you have only one monitor
	world_offset.y = 0
	
	SignalBus.connect("createOverlayElement", create_new_body)
	SignalBus.connect("clearOverlayElements", clearOverlay)
	SignalBus.connect("OverlayElementsEnabled", setWindowCanAppear)
	for oui in spawnedOnStart:
		create_new_body(oui.instantiate(), false, DisplayServer.screen_get_size(0)/2, false)
	
func _physics_process(delta: float) -> void:
	for attractedObj in attractedObjects:
		var posDiff : Vector2 = killArea.position - (attractedObj.position + attractedObj.windowSize/2)
		var portion : float = clamp(inverse_lerp(550, 0, posDiff.length()), 0.1, 1.0)
		var target = posDiff.normalized() * lerp(0.0, attractionSpeed, portion)
		attractedObj.linear_velocity = lerp(attractedObj.linear_velocity, target, 0.05)
	
func create_new_body(object, visible : bool = true, position : Vector2i = DisplayServer.screen_get_size(0)/2, canDissapear : bool = true) -> void:
	if windowCanAppear:
		var new_window : Window = view_window.instantiate()
		
		new_window.world_2d = _MainWindow.world_2d #set the new_window so they all show the same world
		new_window.world_3d = _MainWindow.world_3d
		new_window.world_offset = world_offset
		
		if not visible:
			object.set_visibility_layer_bit(0, false)
			object.set_visibility_layer_bit(1, false)
			object.set_visibility_layer_bit(2, true)
		
		object.position = position
		new_window.setChild(object)# say to the window what object it is following
		if canDissapear:
			windows.append(object)
		
		sceneRoot.add_child.call_deferred(object)
		add_child.call_deferred(new_window)

func clearOverlay() -> void:
	for element in windows:
		element.queue_free()
	windows = []

func setWindowCanAppear(enabled : bool) -> void:
	windowCanAppear = enabled

func _on_attract_body_entered(body: Node2D) -> void:
	if body.is_in_group("overlayElement") && body.is_class("RigidBody2D"):
		if windows.has(body):
			attractedObjects.append(body)

func _on_attract_body_exited(body: Node2D) -> void:
	if body.is_in_group("overlayElement") && body.is_class("RigidBody2D"):
		if windows.has(body):
			attractedObjects.erase(body)

func _on_kill_body_entered(body: Node2D) -> void:
	if body.is_in_group("overlayElement") && body.is_class("RigidBody2D"):
		if windows.has(body):
			attractedObjects.erase(body)
			windows.erase(body)
			body.queue_free()
