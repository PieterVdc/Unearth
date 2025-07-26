extends Node2D
@onready var oOverheadOwnership = Nodelist.list["oOverheadOwnership"]
@onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]

const a = preload("res://Shaders/MaterialInstanceOwnership.tres")
var materialInstanceOwnership = [
	a.duplicate(), # 0
	a.duplicate(), # 1
	a.duplicate(), # 2
	a.duplicate(), # 3
	a.duplicate(), # 4
	a.duplicate(), # 5
	a.duplicate(), # 6
	a.duplicate(), # 7
	a.duplicate(), # 8
]

var flashTimer = 0.0
var currentColorIndex = 0

func _ready():
	for i in Constants.PLAYERS_COUNT:
		materialInstanceOwnership[i].set_shader_parameter("ownerCol", Constants.ownerRoomCol[i])
		materialInstanceOwnership[i].set_shader_parameter("alphaFilled", 0.5)

func _process(delta):
	flashTimer += delta
	var flashIndexes = getFlashIndexes()
	if flashTimer >= 0.1:
		flashTimer = 0.0
		currentColorIndex = (currentColorIndex + 1) % flashIndexes.size()
		var flashColor = getFlashColor(flashIndexes)
		materialInstanceOwnership[Constants.PLAYER_NEUTRAL].set_shader_parameter("ownerCol", flashColor)
	
	for i in Constants.PLAYERS_COUNT:
		materialInstanceOwnership[i].set_shader_parameter("fadeAlpha", 1.0 - oOverheadOwnership.alphaFadeColor[i])

func getFlashIndexes():
	if oCurrentFormat.selected == Constants.KfxFormat:
		return Constants.flashing_colors_kfx
	return Constants.flashing_colors_dk

func getFlashColor(flashIndexes):
	var colorIndex = flashIndexes[currentColorIndex]
	return Constants.ownerRoomCol[colorIndex]
