extends ConfirmationDialog

func _ready():
	get_ok_button().text = "Yes"
	get_cancel_button().text = "No"
	connect("about_to_popup", Callable(self, "_on_about_to_show"))

func _on_about_to_show():
	await get_tree().idle_frame
	get_ok_button().grab_focus()
	size.y = 0 # For when changing label text

func _input(event):
	if visible == false: return
	if event is InputEventKey and event.button_pressed == true:
		if get_viewport().gui_get_focus_owner() is LineEdit: return # If typing some text into somewhere
		match event.keycode:
			KEY_Y:
				get_ok_button().emit_signal("pressed")
			KEY_N:
				get_cancel_button().emit_signal("pressed")
