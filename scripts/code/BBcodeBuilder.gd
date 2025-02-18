extends Node
class_name BBcodeBuilder

func center(text : String) -> String:
	text = "[center]" + text
	text += "[/center]"
	return text
	
func color(text : String, color : Color) -> String:
	text = "[color=" + str(color.to_html(false)) + "]" + text
	text += "[/color]"
	return text
	
func fontSize(text : String, fontSize : int) -> String:
	text = "[font_size=" + str(fontSize) + "]" + text
	text += "[/font_size]"
	return text
