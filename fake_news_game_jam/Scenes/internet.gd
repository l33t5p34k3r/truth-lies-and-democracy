extends Control

@export var messages_count: int = 10

@onready var internet = $"."
@onready var message_scene = preload("res://social_media_message.tscn")

# Reference to the VBoxContainer inside the ScrollContainer
@onready var message_container = $SocialMedia/ScrollContainer/VBoxContainer

var timer_out = false

#func _ready() -> void:
	#spawn_messages()
func _process(delta: float) -> void:
	if timer_out == true:
		spawn_messages()
		timer_out = false

func spawn_messages():
	print("Spawning", messages_count, "messages") 
	
	for i in range(messages_count):
		var message = message_scene.instantiate()
		message_container.add_child(message)   # add to VBoxContainer


func _on_timer_timeout() -> void:
	timer_out = true
