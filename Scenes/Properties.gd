extends MarginContainer
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oDungeonStyleList = Nodelist.list["oDungeonStyleList"]
onready var oDataMapName = Nodelist.list["oDataMapName"]
onready var oDataLof = Nodelist.list["oDataLof"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oAdvancedMapPropertiesCheckBox = Nodelist.list["oAdvancedMapPropertiesCheckBox"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oAdvancedMapProperties = Nodelist.list["oAdvancedMapProperties"]

onready var oMapNameLineEdit = Nodelist.list["oMapNameLineEdit"]
onready var oNameIDLineEdit = Nodelist.list["oNameIDLineEdit"]
onready var oKindLineEdit = Nodelist.list["oKindLineEdit"]
onready var oEnsignPositionLineEdit = Nodelist.list["oEnsignPositionLineEdit"]
onready var oEnsignZoomLineEdit = Nodelist.list["oEnsignZoomLineEdit"]
onready var oPlayersLineEdit = Nodelist.list["oPlayersLineEdit"]
onready var oOptionsLineEdit = Nodelist.list["oOptionsLineEdit"]
onready var oSpeechLineEdit = Nodelist.list["oSpeechLineEdit"]
onready var oLandViewLineEdit = Nodelist.list["oLandViewLineEdit"]
onready var oAuthorLineEdit = Nodelist.list["oAuthorLineEdit"]
onready var oDescriptionLineEdit = Nodelist.list["oDescriptionLineEdit"]
onready var oSettingsXSizeLine = Nodelist.list["oSettingsXSizeLine"]
onready var oSettingsYSizeLine = Nodelist.list["oSettingsYSizeLine"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]

func _ready():
	# Default to hiding ONCE, when you start the editor.
	oAdvancedMapProperties.visible = false

func _on_MapProperties_visibility_changed():
	if is_instance_valid(oDungeonStyleList) == false: return
	if visible == true:
		refresh_dungeon_style_options()
		oMapNameLineEdit.text = oDataMapName.data
		oNameIDLineEdit.text = oDataLof.NAME_ID
		oKindLineEdit.text = oDataLof.KIND
		oEnsignPositionLineEdit.text = oDataLof.ENSIGN_POS
		oEnsignZoomLineEdit.text = oDataLof.ENSIGN_ZOOM
		oPlayersLineEdit.text = oDataLof.PLAYERS
		oOptionsLineEdit.text = oDataLof.OPTIONS
		oSpeechLineEdit.text = oDataLof.SPEECH
		oLandViewLineEdit.text = oDataLof.LAND_VIEW
		oAuthorLineEdit.text = oDataLof.AUTHOR
		oDescriptionLineEdit.text = oDataLof.DESCRIPTION
		oSettingsXSizeLine.text = str(M.xSize)
		oSettingsYSizeLine.text = str(M.ySize)
		
		# Resizing feature isn't implemented, so do not allow changing map format back if you've adjusted size
		if M.xSize != 85 or M.ySize != 85:
			oCurrentFormat.selected = 1
			oCurrentFormat.disabled = true
		else:
			oCurrentFormat.disabled = false
		
		set_format_selection(oCurrentFormat.selected)

func _on_MapFormatSetting_item_selected(index):
	# Clicked using mouse
	oEditor.mapHasBeenEdited = true
	
	set_format_selection(index)

func set_format_selection(setFormat):
	match setFormat:
		0: # Classic format
			oAdvancedMapPropertiesCheckBox.disabled = true
			oAdvancedMapPropertiesCheckBox.pressed = false
			oAdvancedMapProperties.visible = false
		1: # KFX format
			oAdvancedMapPropertiesCheckBox.disabled = false
	
	# When you change format, the object settings that are available also change
	oPlacingSettings.update_placing_tab()
	oInspector.deselect()

func refresh_dungeon_style_options():
	oDungeonStyleList.clear()
	for i in oTextureCache.cachedTextures.size():
		var aaa
		if Constants.TEXTURE_MAP_NAMES.has(i) == true:
			aaa = Constants.TEXTURE_MAP_NAMES[i]
		else:
			aaa = "Untitled"
		oDungeonStyleList.add_item(aaa,i)
	
	# Select the correct one when loading map
	if oDataLevelStyle.data <= oTextureCache.cachedTextures.size():
		oDungeonStyleList.selected = oDataLevelStyle.data

#	for i in oDungeonStyleList.get_children():
#		i.queue_free()
#
#	for i in oTextureCache.cachedTextures.size():
#		var aaa = CheckBox.new()
#		aaa.align = Button.ALIGN_LEFT
#		if i == oDataLevelStyle.data:
#			aaa.pressed = true
#		aaa.group = load("res://Theme/ButtonGroupDungeonStyle.tres")
#		if Constants.TEXTURE_MAP_NAMES.has(i) == true:
#			aaa.text = Constants.TEXTURE_MAP_NAMES[i]
#		else:
#			aaa.text = "Untitled"
#		aaa.size_flags_vertical = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_CENTER
#		aaa.size_flags_horizontal = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_CENTER
#		aaa.connect("pressed",self,"_on_DungeonStyleButtonPressed",[i])
#		oDungeonStyleList.add_child(aaa)
#
#		var bbb = Label.new()
#		bbb.text = "tmapa" + str(i).pad_zeros(3) + ".dat"
#		oDungeonStyleList.add_child(bbb)

func _on_DungeonStyleList_item_selected(value):
	oEditor.mapHasBeenEdited = true
	oDataLevelStyle.data = value
	oTextureCache.set_current_texture_pack()
	oMessage.quick("Loaded : ".plus_file("unearthdata").plus_file("tmapa" + str(value).pad_zeros(3) + ".png"))

func _on_AdvancedMapPropertiesCheckBox_pressed():
	oAdvancedMapProperties.visible = oAdvancedMapPropertiesCheckBox.pressed


func _on_MapNameLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataMapName.set_map_name(new_text)
func _on_AuthorLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.AUTHOR = new_text
func _on_DescriptionLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.DESCRIPTION = new_text
func _on_NameIDLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.NAME_ID = new_text
func _on_KindLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.KIND = new_text
func _on_EnsignPositionLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.ENSIGN_POS = new_text
func _on_EnsignZoomLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.ENSIGN_ZOOM = new_text
func _on_PlayersLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.PLAYERS = new_text
func _on_OptionsLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.OPTIONS = new_text
func _on_SpeechLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.SPEECH = new_text
func _on_LandViewLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.LAND_VIEW = new_text


