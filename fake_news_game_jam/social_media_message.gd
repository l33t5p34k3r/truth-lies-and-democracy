class_name social_media_message
extends Control

static var all_social_media_messages: Array[social_media_message] = []
static var social_media_message_stack_order: Array[social_media_message] = []

var names =[
	"Lui",
	"Soph",
	"Mr. Whiskers",
	"Institute of Caffeinated Sciences",
	"Police"
]

var new_messages =[
	"Today is a sad day, don't you agree?",
	"OMG check out this new album!!",
	"I will try my absolute best to serve you as mayor!",
	"Has anyone seen my coffe? Yet another proof of our latest study!",
	"Safety first... please"
]

var dates =[
	"August 2015",
	"September 2024",
	"April 2025",
	"June 2025",
	"August 2025"
]

func _exit_tree() -> void:
	all_social_media_messages.erase(self)
	social_media_message_stack_order.erase(self)

func register_messsage():
	all_social_media_messages.append(self)
	social_media_message_stack_order.append(self)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	register_messsage()
	add_messages()

func add_messages():
	var content_container = $"."
	
	var article_index = randi_range(0, names.size() - 1)
	
	var name = $VBoxContainer/HBoxContainer/NameLabel
	name.text = names[article_index]
	
	var messages = $VBoxContainer/MessageText
	messages.text = new_messages[article_index]
	
	var date = $VBoxContainer/HBoxContainer/Date
	date.text = dates[article_index]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
