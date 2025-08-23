extends Node2D

@onready var incoming_news = %incoming_news
@onready var calling_someone = %calling_someone
@onready var internet = %internet

#var approved = preload("res://Scenes/approved.tscn")
var dragging_stamp = false


#------------------------- stamping action --------------------------------
#func _process(delta: float) -> void:
	#if dragging:
		#position = get_global_mouse_position()
#
#func inst(pos):
	#var instance = approved.instantiate()
	#instance.position = pos
	#add_child(instance)

func _on_stamp_approved_dragging_stamp() -> void:
	dragging_stamp = true
	print("Player is dragging stamp!")

#func _on_stamp_approved_stamping() -> void:
	#inst(get_global_mouse_position())

#---------------------------Buttons------------------------------------------
func _on_call_someone_pressed() -> void:
	calling_someone.show()


func _on_check_internet_pressed() -> void:
	internet.show()


func _on_write_news_pressed() -> void:
	incoming_news.show()

func _on_exit_pressed() -> void:
	get_tree().quit()
