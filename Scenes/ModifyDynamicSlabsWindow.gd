extends WindowDialog
onready var oDynamicSlabVoxelView = Nodelist.list["oDynamicSlabVoxelView"]
onready var oVariationInfoLabel = Nodelist.list["oVariationInfoLabel"]
onready var oDynamicSlabIDSpinBox = Nodelist.list["oDynamicSlabIDSpinBox"]
onready var oDynamicSlabIDLabel = Nodelist.list["oDynamicSlabIDLabel"]
onready var oGridContainerDynamicColumns3x3 = Nodelist.list["oGridContainerDynamicColumns3x3"]
onready var oDkSlabs = Nodelist.list["oDkSlabs"]
onready var oVariationNumberSpinBox = Nodelist.list["oVariationNumberSpinBox"]
onready var oSlabPalette = Nodelist.list["oSlabPalette"]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var columnSpinBoxArray = []

# Called when the node enters the scene tree for the first time.
func _ready():
#	for i in 2:
#		yield(get_tree(),'idle_frame')
#	Utils.popup_centered(self)
	
	for number in 9:
		var id = CustomSpinBox.new()
		id.max_value = 2047
		id.connect("value_changed",oDynamicSlabVoxelView,"_on_DynamicSlab3x3ColumnSpinBox_value_changed")
		id.connect("value_changed",self,"_on_DynamicSlab3x3ColumnSpinBox_value_changed")
		oGridContainerDynamicColumns3x3.add_child(id)
		columnSpinBoxArray.append(id)
	
	oDynamicSlabVoxelView.initialize()
	
	yield(get_tree(),'idle_frame')
	#_on_DynamicSlabIDSpinBox_value_changed(0)
	
	#variation_changed(0)

func variation_changed(variation):
	variation = int(variation)
	var slabID = oDynamicSlabIDSpinBox.value
	#variation
	var constructString = ""
	#var byte = (slabID * 28) + variation
	#constructString += "Byte " + str(byte) + ' - ' + str(byte)
	#constructString += '\n'
	
	if slabID < 42:
		if variation != 27:
			match variation % 9:
				0: constructString += "South"
				1: constructString += "West"
				2: constructString += "North"
				3: constructString += "East"
				4: constructString += "South West"
				5: constructString += "North West"
				6: constructString += "North East"
				7: constructString += "South East"
				8: constructString += "All direction"
		else:
			constructString += "Center"
		
		constructString += '\n'
	
	if variation < 9:
		constructString += ""
	elif variation < 18:
		constructString += "Near lava"
	elif variation < 27:
		constructString += "Near water"
	
	oVariationInfoLabel.text = constructString

#enum dir {
#	s = 0
#	w = 1
#	n = 2
#	e = 3
#	sw = 4
#	nw = 5
#	ne = 6
#	se = 7
#	all = 8
#	center = 27
#}


func _on_DynamicSlabIDSpinBox_value_changed(value):
	var slabName = "Unknown"
	value = int(value)
	if Slabs.data.has(value):
		slabName = Slabs.data[value][Slabs.NAME]
	oDynamicSlabIDLabel.text = slabName
	
	update_columns_ui()

func _on_VariationNumberSpinBox_value_changed(value):
	update_columns_ui()

func update_columns_ui():
	
	var variation = int(oVariationNumberSpinBox.value)
	var slabID = int(oDynamicSlabIDSpinBox.value)
	
	var variationStart = (slabID * 28)
	if slabID >= 42:
		variationStart = (42 * 28) + (8 * (slabID - 42))
	variation += variationStart
	
	if variation >= 1304:
		return
	
	for i in columnSpinBoxArray.size():
		columnSpinBoxArray[i].disconnect("value_changed",self,"_on_DynamicSlab3x3ColumnSpinBox_value_changed")
		var clmIndex = oDkSlabs.dat[variation][i]
		columnSpinBoxArray[i].value = clmIndex
		columnSpinBoxArray[i].connect("value_changed",self,"_on_DynamicSlab3x3ColumnSpinBox_value_changed")

func _on_DynamicSlab3x3ColumnSpinBox_value_changed(value):
	var variation = int(oVariationNumberSpinBox.value)
	var slabID = int(oDynamicSlabIDSpinBox.value)
	
	var variationStart = (slabID * 28)
	if slabID >= 42:
		variationStart = (42 * 28) + (8 * (slabID - 42))
	variation += variationStart
	
	for y in 3:
		for x in 3:
			var i = (y*3) + x
			var clmIndex = oGridContainerDynamicColumns3x3.get_child(i).value
			oDkSlabs.dat[variation][i] = clmIndex
			#oSlabPalette.slabPal[variation][i] = clmIndex # This may not be working
