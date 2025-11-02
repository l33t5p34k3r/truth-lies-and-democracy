extends Control

const SINGLE_STAT = preload("uid://b8q34f51dcu65")
@onready var stat_container: VBoxContainer = %StatContainer


func _ready():
	Manager.set_mouse_cursor(Manager.MOUSE_MODE.NONE)
	cursor_connect_children(self)
	# get stat names
	var stat_display_names := Manager.get_stat_names_pretty()
	var stat_display_values := Manager.get_stat_values_pretty()
	for stat in Manager.STATS.values():
		
		var stat_display :SingleStatContainer= SINGLE_STAT.instantiate()
		
		stat_display.text_stat_name = stat_display_names[stat]
		stat_display.text_stat_result = stat_display_values[stat]
		
		stat_container.add_child(stat_display)

func cursor_connect_children(node: Node):
	if node is BaseButton:
		node.mouse_entered.connect(_on_control_mouse_entered)
		node.mouse_exited.connect(_on_control_mouse_exited)
	
	for child in node.get_children():
		cursor_connect_children(child)

func _on_control_mouse_entered():
	Manager.set_mouse_cursor(Manager.MOUSE_MODE.POINTING)

func _on_control_mouse_exited():
	Manager.set_mouse_cursor(Manager.MOUSE_MODE.NONE)


func _on_continue_pressed() -> void:
	Manager.current_round += 1
	
	get_tree().change_scene_to_file("res://Scenes/paper_playground.tscn")
	
	print("TODO: final game over screen")
