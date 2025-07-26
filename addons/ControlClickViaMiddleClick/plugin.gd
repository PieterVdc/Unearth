@tool
extends EditorPlugin

var mainScreen = ''

func _enter_tree():
	connect("main_screen_changed", Callable(self, "main_screen_changed"))

func _input(event):
	if event is InputEventMouseButton and (event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE):
		if mainScreen == "Script":
			await get_tree().idle_frame # Allows things in script panel to still be closed by middle click
			var ev = InputEventKey.new()
			ev.button_pressed = true
			ev.keycode = KEY_CTRL
			get_tree().input_event(ev)

			var evt = InputEventMouseButton.new()
			evt.button_index = MOUSE_BUTTON_LEFT
			evt.position = get_viewport().get_mouse_position()
			evt.button_pressed = true
			evt.control = true
			get_tree().input_event(evt)
			evt.button_pressed = false
			get_tree().input_event(evt)

func main_screen_changed(screen):
	mainScreen = screen
