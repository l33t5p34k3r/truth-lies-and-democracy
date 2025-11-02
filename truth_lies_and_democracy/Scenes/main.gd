extends Node

# : Dictionary[String, Node2D]
var loaded_scenes  = {}
var is_fake_root = {}
var active_scene := Manager.SCENE.DESKTOP

# each main scene must provide a "make_active"and "make_inactive" function

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for scene in Manager.SCENE.values():
		var new_scene = Manager.scene_resource[scene].instantiate()
		var actual_root = new_scene
		if new_scene is Control:
			var canvas_layer = CanvasLayer.new()
			canvas_layer.add_child(new_scene)
			actual_root = canvas_layer
			is_fake_root[scene] = true
		else:
			is_fake_root[scene] = false
			# new_scene.set_anchors_preset(Control.PRESET_FULL_RECT)
		self.add_child(actual_root)
		loaded_scenes[scene] = actual_root
		make_scene_inactive(scene)

	make_scene_active(active_scene)

func switch_scene(new_scene:Manager.SCENE):
	make_scene_inactive(active_scene)
	make_scene_active(new_scene)


func make_scene_inactive(scene:Manager.SCENE):
	var target_scene = loaded_scenes[scene]
	if is_fake_root[scene]:
		target_scene.get_child(0).make_inactive()
	else:
		target_scene.make_inactive()
	target_scene.visible = false
	target_scene.process_mode = Node.PROCESS_MODE_DISABLED

func make_scene_active(scene:Manager.SCENE):
	active_scene = scene
	var target_scene = loaded_scenes[scene]
	target_scene.visible = true
	target_scene.process_mode = Node.PROCESS_MODE_INHERIT
	if is_fake_root[scene]:
		target_scene.get_child(0).make_active()
	else:
		target_scene.make_active()
	
