extends Node2D
@onready var oTMapLoader = Nodelist.list["oTMapLoader"]
@onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
@onready var oUi = Nodelist.list["oUi"]
@onready var oOpenMap = Nodelist.list["oOpenMap"]


func _enter_tree():
	print("Unearth v"+Version.full)
	Nodelist.start(self)


func _ready():
	Nodelist.done()
	Settings.initialize_settings()
	initialize_window_settings()
	oUi.initialize_window_desired_values()
	Graphics.load_extra_images_from_harddrive()
	oOpenMap.start()


func initialize_window_settings():
	if Settings.cfg_has_setting("ui_scale") == false:
		var desktopResolution = DisplayServer.screen_get_size()
		var scaleValue = desktopResolution.x / 1920.0
		scaleValue = round(scaleValue * 100.0) / 100.0
		oUi.set_ui_scale(scaleValue)
	
	get_window().borderless = false
	
	if Settings.cfg_has_setting("editor_window_size") == true:
		var getStoredWindowSize = Settings.read_cfg("editor_window_size")
		get_window().size = Vector2(max(720, getStoredWindowSize.x), max(720, getStoredWindowSize.y))
	else:
		var sameSize = DisplayServer.screen_get_size().y * 0.9
		get_window().size = Vector2(max(720, sameSize), max(720, sameSize))
	
	if Settings.cfg_has_setting("editor_window_position") == true:
		var newPos = Settings.read_cfg("editor_window_position")
		var desktopRes = DisplayServer.screen_get_size()
		newPos.x = clamp(newPos.x, 0, desktopRes.x-(desktopRes.x*0.05)) # 5% from the edge
		newPos.y = clamp(newPos.y, 0, desktopRes.y-(desktopRes.y*0.05))
		get_window().position = newPos
	else:
		OS.center_window()
	
	if Settings.cfg_has_setting("editor_window_maximized_state") == true:
		get_window().mode = Window.MODE_MAXIMIZED if (Settings.read_cfg("editor_window_maximized_state")) else Window.MODE_WINDOWED
	else:
		get_window().mode = Window.MODE_MAXIMIZED if (true) else Window.MODE_WINDOWED
	
	if Settings.cfg_has_setting("editor_window_fullscreen_state") == true:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (Settings.read_cfg("editor_window_fullscreen_state")) else Window.MODE_WINDOWED
	else:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (false) else Window.MODE_WINDOWED
