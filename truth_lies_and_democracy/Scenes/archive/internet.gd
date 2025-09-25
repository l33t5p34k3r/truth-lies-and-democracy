extends Control

@export var messages_count: int = 10

@onready var internet = $"."
const message_scene = preload("uid://depviawpyn3jn")

@onready var message_container = $SocialMedia/ScrollContainer/VBoxContainer
@onready var timer = $Timer

var spawned_count = 0

func _ready() -> void:
	timer.start()


func _on_timer_timeout() -> void:
	if spawned_count < messages_count:
		spawn_messages()
		spawned_count += 1
	else:
		timer.stop()

func spawn_messages():
	print("Spawning message", spawned_count + 1 , "of" , messages_count, "messages") 
	
	var message = message_scene.instantiate()
	message_container.add_child(message)   # add to VBoxContainer



func _on_back_pressed() -> void:
	$".".hide()
