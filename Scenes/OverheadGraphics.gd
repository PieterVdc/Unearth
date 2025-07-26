extends Node
@onready var oGame2D = Nodelist.list["oGame2D"]
@onready var oDataSlab = Nodelist.list["oDataSlab"]
@onready var oDataClmPos = Nodelist.list["oDataClmPos"]
@onready var oDataClm = Nodelist.list["oDataClm"]
@onready var oDataSlx = Nodelist.list["oDataSlx"]
@onready var oTMapLoader = Nodelist.list["oTMapLoader"]
@onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
@onready var oUndoStates = Nodelist.list["oUndoStates"]
@onready var oQuickMapPreviewDisplay = Nodelist.list["oQuickMapPreviewDisplay"]
@onready var oMessage = Nodelist.list["oMessage"]
@onready var oTextureAnimation = Nodelist.list["oTextureAnimation"]
@onready var oReadPalette = Nodelist.list["oReadPalette"]
@onready var oFlashingColumns = Nodelist.list["oFlashingColumns"]

signal column_graphics_completed

var overheadImgData = Image.new()
var overheadTexData = ImageTexture.new()

var arrayOfColorRects = []

var thread = Thread.new()
var semaphore = Semaphore.new()
var mutex = Mutex.new()
var job_queue = []
var pixel_data = PackedByteArray()

func update_full_overhead_map():
	var CODETIME_START = Time.get_ticks_msec()
	
	if arrayOfColorRects.is_empty() == true:
		initialize_display_fields()
	else:
		update_display_fields_size()
	
	var shapePositionArray = []
	var totalPositions = M.xSize * M.ySize
	shapePositionArray.resize(totalPositions)
	var index = 0
	for ySlab in range(0, M.ySize):
		for xSlab in range(0, M.xSize):
			shapePositionArray[index] = Vector2(xSlab, ySlab)
			index += 1
	
#	for i in 2: # Helps prevent the column updating from freezing the editor so much.
#		yield(get_tree(),'idle_frame')
	call_deferred("overhead2d_update_rect_single_threaded", shapePositionArray)
	print('Overhead graphics done in '+str(Time.get_ticks_msec()-CODETIME_START)+'ms')


func overhead2d_update_rect_single_threaded(shapePositionArray):
	pixel_data = generate_pixel_data(pixel_data, shapePositionArray)
	overheadImgData.create_from_data(M.xSize * 3, M.ySize * 3, false, Image.FORMAT_RGB8, pixel_data)
	overheadTexData.create_from_image(overheadImgData) #,0
	emit_signal("column_graphics_completed")

const subtile3x3 = [
	Vector2(0,0), Vector2(1,0), Vector2(2,0),
	Vector2(0,1), Vector2(1,1), Vector2(2,1),
	Vector2(0,2), Vector2(1,2), Vector2(2,2)
]

func generate_pixel_data(pixData, shapePositionArray):
	var CODETIME_START = Time.get_ticks_msec()
	var width = M.xSize * 3
	var height = M.ySize * 3
	pixData.resize(width * height * 3)
	var clmPosBuffer = oDataClmPos.buffer
	var clmPosWidth = oDataClmPos.width
	var clmCubes = oDataClm.cubes
	var clmFloorTexture = oDataClm.floorTexture
	var cubeTex = Cube.tex
	var cubeCount = Cube.CUBES_COUNT
	var sideTop = Cube.MARGIN_TOP
	var widthBytes = width * 3
	
	var columnFaceCache = []
	columnFaceCache.resize(oDataClm.column_count)
	columnFaceCache.fill(-1)
	
	var posIndex = 0
	var totalPositions = shapePositionArray.size()
	while posIndex < totalPositions:
		var pos = shapePositionArray[posIndex]
		var basePosX = pos.x * 3
		var basePosY = pos.y * 3
		var baseSeekPos = basePosY * clmPosWidth + basePosX
		var basePixelIndex = basePosY * widthBytes + basePosX * 3
		
		for offsetY in range(3):
			var rowSeekPos = baseSeekPos + offsetY * clmPosWidth
			var rowPixelIndex = basePixelIndex + offsetY * widthBytes
			for offsetX in range(3):
				var seekPos = (rowSeekPos + offsetX) * 2
				clmPosBuffer.seek(seekPos)
				var clmIndex = abs(clmPosBuffer.get_16())
				
				var cubeFace = columnFaceCache[clmIndex]
				if cubeFace == -1:
					var cubeArray = clmCubes[clmIndex]
					cubeFace = clmFloorTexture[clmIndex]
					for i in range(7, -1, -1):
						var cubeID = cubeArray[i]
						if cubeID != 0:
							cubeFace = cubeTex[cubeID][sideTop] if cubeID <= cubeCount else 1
							break
					columnFaceCache[clmIndex] = cubeFace
				
				var pixelIdx = rowPixelIndex + offsetX * 3
				pixData[pixelIdx] = (cubeFace >> 16) & 0xFF
				pixData[pixelIdx + 1] = (cubeFace >> 8) & 0xFF
				pixData[pixelIdx + 2] = cubeFace & 0xFF
		
		posIndex += 1
	
	print('pixData Codetime: ' + str(Time.get_ticks_msec() - CODETIME_START) + 'ms')
	return pixData





func initialize_display_fields():
	arrayOfColorRects.clear() # just in case
	
	# Default
	if oTMapLoader.cachedTextures.size() > 0:
		createDisplayField(oDataLevelStyle.data, 0) # 0 means "Show Default Style"
	
	# Slab styles
	for map in oTMapLoader.cachedTextures.size():
		createDisplayField(map, map+1)

func createDisplayField(setMap, showStyle):
	var displayField = ColorRect.new()
	displayField.size = Vector2(M.xSize * 96, M.ySize * 96)
	displayField.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var mat = ShaderMaterial.new()
	mat.gdshader = preload("res://Shaders/display_texture_2d.gdshader")
	displayField.material = mat
	
	if showStyle != 0:
		mat.set_shader_parameter("tmap_A_top", oTMapLoader.cachedTextures[setMap][0])
		mat.set_shader_parameter("tmap_A_bottom", oTMapLoader.cachedTextures[setMap][1])
		mat.set_shader_parameter("tmap_B_top", oTMapLoader.cachedTextures[setMap][2])
		mat.set_shader_parameter("tmap_B_bottom", oTMapLoader.cachedTextures[setMap][3])
	
	mat.set_shader_parameter("showOnlySpecificStyle", showStyle)
	mat.set_shader_parameter("fieldSizeInSubtiles", Vector2((M.xSize*3), (M.ySize*3)))
	mat.set_shader_parameter("animationDatabase", oTextureAnimation.animation_database_texture)
	mat.set_shader_parameter("viewTextures", overheadTexData)
	
	mat.set_shader_parameter("columnPosData", oFlashingColumns.columnPosTexData)
	mat.set_shader_parameter("columnsetPosData", oFlashingColumns.columnsetPosTexData)
	mat.set_shader_parameter("variationPosData", oFlashingColumns.variationPosTexData)
	
	mat.set_shader_parameter("slxData", oDataSlx.slxTexData)
	mat.set_shader_parameter("slabIdData", oDataSlab.idTexData)
	mat.set_shader_parameter("palette_texture", oReadPalette.palette_image_texture)
	mat.set_shader_parameter("supersampling_level", Settings.get_setting("ssaa"))
	mat.set_shader_parameter("flashingColumn", -1)
	mat.set_shader_parameter("flashingColumnset", -1)
	mat.set_shader_parameter("flashingVariation", -1)
	for i in 9:
		mat.set_shader_parameter("flashingColumnset" + str(i), -1)
	mat.set_shader_parameter("flashIntensity", 0.0)
	
	arrayOfColorRects.append(displayField)
	oGame2D.add_sibling(self, displayField)

func update_display_fields_size():
	for displayField in arrayOfColorRects:
		displayField.size = Vector2(M.xSize * 96, M.ySize * 96)
		displayField.material.set_shader_parameter("fieldSizeInSubtiles", Vector2((M.xSize*3), (M.ySize*3)))

func update_ssaa_level(level):
	for displayField in arrayOfColorRects:
		displayField.material.set_shader_parameter("supersampling_level", level)



