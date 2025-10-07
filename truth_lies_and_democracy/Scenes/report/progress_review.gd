extends Control

const SINGLE_STAT = preload("uid://b8q34f51dcu65")
@onready var stat_container: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/StatContainer


func _ready():
	# get stat names
	var stat_display_names := Manager.get_stat_names_pretty()
	var stat_display_values := Manager.get_stat_values_pretty()
	for stat in Manager.STATS.values():
		
		var stat_display :SingleStatContainer= SINGLE_STAT.instantiate()
		
		stat_display.text_stat_name = stat_display_names[stat]
		stat_display.text_stat_result = stat_display_values[stat]
		
		stat_container.add_child(stat_display)


func _on_continue_pressed() -> void:
	Manager.current_round += 1
	
	get_tree().change_scene_to_file("res://Scenes/paper_playground.tscn")
	
	print("TODO: switch to next scene")
	pass # Replace with function body.
