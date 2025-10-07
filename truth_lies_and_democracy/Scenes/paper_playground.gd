# Desktop.gd - Main desktop scene script
extends Node2D

@export var paper_textures: Array[Texture2D]

@onready var paper_scene = preload("res://Scenes/paper.tscn")

@onready var confirm_button: Button = $CanvasLayer/Control/Button


var paper_array: Array[Paper] = []
var approved_paper: Array[Paper] = []

var paper_container = Node2D.new()


func load_papers():
	var file = FileAccess.open("res://Assets/papers/papers.json", FileAccess.READ)
	var raw = file.get_as_text()
	var json = JSON.new()
	json.parse(raw)
	var papers = json.data

	spawn_papers(papers)


func _ready():
	load_papers()


func spawn_papers(papers : Dictionary):
	var container = Node2D.new()
	container.name = "PaperContainer"
	add_child(container)
	
	for paper_set in papers.keys():
		var paper_data = papers[paper_set]
		if paper_set == str(Manager.current_round):
			for story in paper_data:
			
				var paper :Paper= paper_scene.instantiate()
				
				var paper_headline : String = story.get("news_headline", "")
				var paper_content : String = story.get("news_content", "")
				#TODO add defaults for production
				var paper_is_fake : bool = story.get("news_fake")
				
				paper.paper_headline = paper_headline
				paper.paper_content = paper_content
				paper.paper_is_fake = paper_is_fake
				
				paper.paper_color = Color(
					randf_range(0.9, 1.0),
					randf_range(0.9, 1.0),
					randf_range(0.8, 1.0),
					1.0
				)
				
				paper.position = Vector2(
					randf_range(200, 1080),
					randf_range(200, 520)
				)
				
				paper.rotation = randf_range(-0.3, 0.3)
				
				container.add_child(paper)
				paper_array.append(paper)
				paper.got_stamped.connect(on_paper_stamped)


func on_paper_stamped() -> void:
	confirm_button.visible = true

func _on_confirm_button_pressed() -> void:
	# TODO: check if we are allowed to call deferred when this current object will be deleted this tick?
	SignalHandler.scene_changed.emit.call_deferred()
	get_tree().change_scene_to_file("res://Scenes/report/ProgressReview.tscn")
