extends Camera3D
@onready var oVoxelObjectView = $"../../.."
@onready var oVoxelCameraPivotPoint = $".."

var rotationSensitivity = 0.5
var cameraShiftSpeed = 0.02

func _input(event):
	if oVoxelObjectView.is_visible_in_tree() == false: return
	if Rect2( oVoxelObjectView.global_position, oVoxelObjectView.size ).has_point(oVoxelObjectView.get_global_mouse_position()) == false: return
	
	if event.is_action_pressed("zoom_in"):
		if size > 0.1+3:
			size -= 3
	if event.is_action_pressed("zoom_out"):
		if size < 16384-3:
			size += 3

func _process(delta):
	if oVoxelObjectView.displayingType == oVoxelObjectView.DK_SLABSET:
		oVoxelCameraPivotPoint.position.z = lerp(oVoxelCameraPivotPoint.position.z, (oVoxelObjectView.viewObject*4), cameraShiftSpeed)
		oVoxelCameraPivotPoint.position.x = lerp(oVoxelCameraPivotPoint.position.x, (oVoxelObjectView.viewObject*4), cameraShiftSpeed)
	else:
		oVoxelCameraPivotPoint.position.z = lerp(oVoxelCameraPivotPoint.position.z, oVoxelObjectView.viewObject*2, cameraShiftSpeed)
		oVoxelCameraPivotPoint.position.x = lerp(oVoxelCameraPivotPoint.position.x, oVoxelObjectView.viewObject*2, cameraShiftSpeed)
