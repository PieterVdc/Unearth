extends ColorRect

var clingTo = null
var allowDragRelease = false



func highlight(node):
	clingTo = node
	visible = true

func _process(delta):
	if is_instance_valid(clingTo):
		size = clingTo.size
		global_position = clingTo.global_position
		
		var current_focus_control = get_viewport().gui_get_focus_owner()
		if is_instance_valid(current_focus_control) and current_focus_control is LineEdit:
			clingTo = null
			visible = false

func _input(event):
	if visible == false: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.button_pressed == true:
			await get_tree().idle_frame # otherwise is overwritten by what's inside of ResearchableItem gui_input
			clingTo = null
			visible = false
		else:
			if allowDragRelease == true:
				clingTo = null
				visible = false
