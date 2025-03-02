extends PanelContainer

var lineColor : Color = Color.WHITE
var pressed : bool = false
var currentLine : Line2D = null
@export var paintingPanel : Panel
@export var menuBar : HBoxContainer
@export var colorPicker : ColorPickerButton

func setPanelSize(newSize : Vector2) -> void:
	paintingPanel.custom_minimum_size = newSize

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_MASK_RIGHT:
		
		var newLine : Line2D = Line2D.new()
		newLine.width = 5
		newLine.default_color = lineColor
		currentLine = newLine
		pressed = event.pressed
		if pressed:
			paintingPanel.add_child(newLine)
	if event is InputEventMouseMotion && pressed:
		if withinDrawingBoard(event.position):
			currentLine.add_point(event.position - Vector2(0, 25))

func withinDrawingBoard(position : Vector2) -> bool:
	if position.x > 0 && position.x < size.x && position.y > menuBar.size.y && position.y < size.y:
		return true
	return false

func _on_color_picker_button_color_changed(color: Color) -> void:
	lineColor = color

func _on_undo_button_button_up() -> void:
	if paintingPanel.get_child_count() > 0:
		paintingPanel.get_child(-1).queue_free()

func _on_clear_button_button_up() -> void:
	for line in paintingPanel.get_children():
		line.queue_free()


func _on_color_picker_button_picker_created() -> void:
	var picker : Popup = colorPicker.get_popup()
	picker.always_on_top = true
