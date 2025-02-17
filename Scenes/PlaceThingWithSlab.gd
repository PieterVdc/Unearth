extends Node
onready var oInstances = Nodelist.list["oInstances"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oPlaceLockedCheckBox = Nodelist.list["oPlaceLockedCheckBox"]
onready var oLavaEffectPercent = Nodelist.list["oLavaEffectPercent"]
onready var oWaterEffectPercent = Nodelist.list["oWaterEffectPercent"]
onready var oSelector = Nodelist.list["oSelector"]

onready var dir = oSlabPlacement.dir

# The way things placed from slabs.tng works, is that we use the same coordinates (via bitmask and fullVariationIndex) as what's in slabs.dat/clm (level 1000)
# Except we change the positions based on some placement rules.
# For example the Prison bars need extra rules for detecting nearby walls, but the original slab cubes did not need these rules.
# So objects have their own placement rules, though we use the original bitmask/fullVariationIndex (from oSlabPlacement) as a basis to work from.

func place_slab_objects(xSlab, ySlab, slabID, ownership, clmIndexGroup, bitmask, surrID, bitmaskType):
	oInstances.delete_attached_instances_on_slab(xSlab, ySlab)
	
	if slabID == Slabs.PRISON:
		bitmask = prison_bar_bitmask(slabID, surrID)
	elif slabID == Slabs.WATER:
		if Random.rng.randf_range(0.0, 100.0) < oWaterEffectPercent.value:
			var xSubtile = (xSlab*3) + Random.randi_range(0,2) + 0.5
			var ySubtile = (ySlab*3) + Random.randi_range(0,2) + 0.5
			var zSubtile = 0
			var createAtPos = Vector3(xSubtile, ySubtile, zSubtile)
			oInstances.place_new_thing(Things.TYPE.EFFECTGEN, 2, createAtPos, ownership)
	elif slabID == Slabs.LAVA:
		if Random.rng.randf_range(0.0, 100.0) < oLavaEffectPercent.value:
			var xSubtile = (xSlab*3) + Random.randi_range(0,2) + 0.5
			var ySubtile = (ySlab*3) + Random.randi_range(0,2) + 0.5
			var zSubtile = 0
			var createAtPos = Vector3(xSubtile, ySubtile, zSubtile)
			oInstances.place_new_thing(Things.TYPE.EFFECTGEN, 1, createAtPos, ownership)
	
	if Slabs.is_door(slabID):
		create_door_thing(xSlab, ySlab, ownership)
	
	for i in range(9): # iterate over the range of 0-8, assuming 9 subtiles per variation
		var variation = int(clmIndexGroup[i] / 9) # Convert to int for safety, as division of ints in GDScript results in float
		var convertedSubtile = clmIndexGroup[i] % 9
		var objectStuff = get_object(variation, convertedSubtile) # Pass slabVar and datSubtile to the get_object function
		if objectStuff.size() > 0:
			oInstances.spawn_attached(xSlab, ySlab, slabID, ownership, i, objectStuff)

func get_object(variation, subtile):
	if variation < Slabset.tng.size():
		for objectStuff in Slabset.tng[variation]:
			if subtile == objectStuff[Slabset.obj.SUBTILE]: # Assuming the third element in objectStuff array is the subtile number
				return objectStuff
	return [] # Return an empty array if no objectStuff is found or if slabVar is out of range


func create_door_thing(xSlab, ySlab, ownership):
	var createAtPos = Vector3((xSlab*3)+1.5, (ySlab*3)+1.5, 5)
	
	var rememberLockedState = 0 # This is the fallback value if oPlaceLockedCheckBox isn't being used
	
	# Destroy existing door thing
	var doorID = oInstances.get_node_on_subtile(createAtPos.x, createAtPos.y, "Door")
	if is_instance_valid(doorID) == true:
		rememberLockedState = doorID.doorLocked
		
		doorID.position = Vector2(-500000,-500000) # Not sure if this is necessary
		doorID.queue_free()
	
	# Recreate door thing
	var id = oInstances.place_new_thing(Things.TYPE.DOOR, 0, createAtPos, ownership) #subtype determined in oInstances
	id.doorLocked = rememberLockedState
	
	# Overwrite locked state with ui checkbox setting
	if oPlaceLockedCheckBox.visible == true:
		# Only affect the slab under cursor
		#if xSlab == oSelector.cursorTile.x and ySlab == oSelector.cursorTile.y:
		# Set locked state to checkbox state
		if oPlaceLockedCheckBox.pressed == true:
			id.doorLocked = 1
		else:
			id.doorLocked = 0
	
	id.update_spinning_key()

func prison_bar_bitmask(slabID, surrID):
	var bitmask = 0
	if Slabs.data[ surrID[dir.s] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.s]: bitmask += 1
	if Slabs.data[ surrID[dir.w] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.w]: bitmask += 2
	if Slabs.data[ surrID[dir.n] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.n]: bitmask += 4
	if Slabs.data[ surrID[dir.e] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.e]: bitmask += 8
	return bitmask
