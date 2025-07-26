extends Control
@onready var oTextureAnimation = Nodelist.list["oTextureAnimation"]

var offset = Vector2(0,-35)

func _ready():
	visible = false
	await get_tree().idle_frame
	visible = false

func _process(delta):
	if visible == true:
		global_position = get_global_mouse_position() + offset

func set_text(txt):
	$PanelContainer/HBoxContainer/TooltipPicture.visible = false
	$PanelContainer/HBoxContainer/Label.text = txt
	if txt == "":
		visible = false
	else:
		visible = true
		RenderingServer.canvas_item_set_z_index(get_canvas_item(), 10)
	#$TooltipPicture.visible = false
#	yield(get_tree(),'idle_frame')
#	yield(get_tree(),'idle_frame')
#	rect_size = Vector2(0,0)
	
func get_text():
	return $PanelContainer/HBoxContainer/Label.text

func set_floortexture(floorTextureValue):
	var oTooltipPic = $PanelContainer/HBoxContainer/TooltipPicture
	oTooltipPic.visible = true
	
	visible = true
	RenderingServer.canvas_item_set_z_index(get_canvas_item(), 10)
	#$PanelContainer/Label.text = ""
	
	var dataImage = Image.new()
	var dataTexture = ImageTexture.new()
	dataImage.create(1, 1, false, Image.FORMAT_RGB8)
	dataTexture.create_from_image(dataImage) #,0

	false # dataImage.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	dataImage.set_pixel(0, 0, Color8(int(floorTextureValue) >> 16 & 255, int(floorTextureValue) >> 8 & 255, int(floorTextureValue) & 255))
	false # dataImage.unlock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	dataTexture.set_data(dataImage)
	
	# Get required texture resources
	var oTMapLoader = Nodelist.list["oTMapLoader"]
	var oReadPalette = Nodelist.list["oReadPalette"]
	var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
	
	oTooltipPic.material.set_shader_parameter("showOnlySpecificStyle", 0)
	oTooltipPic.material.set_shader_parameter("slxData", preload("res://Shaders/Black3x3.png"))
	oTooltipPic.material.set_shader_parameter("slabIdData", preload("res://Shaders/Black3x3.png"))
	oTooltipPic.material.set_shader_parameter("fieldSizeInSubtiles", Vector2(1, 1))
	oTooltipPic.material.set_shader_parameter("animationDatabase", oTextureAnimation.animation_database_texture)
	oTooltipPic.material.set_shader_parameter("viewTextures", dataTexture)
	
	if oTMapLoader.cachedTextures.size() > 0 and oDataLevelStyle.data >= 0 and oDataLevelStyle.data < oTMapLoader.cachedTextures.size():
		var currentPack = oTMapLoader.cachedTextures[oDataLevelStyle.data]
		if currentPack != null:
			oTooltipPic.material.set_shader_parameter("tmap_A_top", currentPack[0])
			oTooltipPic.material.set_shader_parameter("tmap_A_bottom", currentPack[1])
			oTooltipPic.material.set_shader_parameter("tmap_B_top", currentPack[2])
			oTooltipPic.material.set_shader_parameter("tmap_B_bottom", currentPack[3])
	
	var paletteTexture = oReadPalette.get_palette_texture()
	if paletteTexture != null:
		oTooltipPic.material.set_shader_parameter("palette_texture", paletteTexture)
