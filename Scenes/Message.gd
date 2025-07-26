extends Control
@onready var oUiMessages = Nodelist.list["oUiMessages"]

var scnQuickMsg = preload('res://Scenes/QuickMsgInstance.tscn')
var scnBigMsg = preload('res://Scenes/BigMessageInstance.tscn')
var recentMessages = {}

func quick(string):
	var currentTime = Time.get_ticks_msec() / 1000.0
	if recentMessages.has(string):
		var lastTime = recentMessages[string]
		if currentTime - lastTime < 3.0:
			return
	recentMessages[string] = currentTime
	var id = scnQuickMsg.instantiate()
	id.show_then_fade(string)
	$VBoxContainer.add_child(id)

func big(windowTitle, dialogText):
	for i in 2:
		await get_tree().idle_frame # Fixes a problem where error messages are off center when they popup too early
	
	# Do not show big message if one already exists (which has the same message)
	for i in oUiMessages.get_children():
		if i is AcceptDialog:
			if i.window_title == windowTitle and i.dialog_text == dialogText:
				return
	
	var id = scnBigMsg.instantiate()
	# Don't go smaller than 250 pixels wide
	# For longer lines, put message on two lines
	id.size.x = (dialogText.length()*11) * 0.5
	id.size.x = clamp(id.size.x, 240, 1280)
	id.size.y = 0
	id.window_title = windowTitle
	id.dialog_text = dialogText
	
	id.get_label().offset_left = 20
	
	oUiMessages.add_child(id)
	Utils.popup_centered(id)
