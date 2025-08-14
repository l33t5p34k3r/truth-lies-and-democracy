extends Node2D

@onready var incoming_news = %incoming_news
@onready var calling_someone = %calling_someone
@onready var internet = %internet
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_call_someone_pressed() -> void:
	calling_someone.show()


func _on_check_internet_pressed() -> void:
	internet.show()


func _on_write_news_pressed() -> void:
	incoming_news.show()


func _on_button_pressed() -> void:
	get_tree().quit()
