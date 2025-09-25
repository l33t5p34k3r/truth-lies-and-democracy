# Desktop.gd - Main desktop scene script
extends Node2D

@export var paper_textures: Array[Texture2D]
@export var paper_count: int = 5

@onready var paper_scene = preload("res://Scenes/paper.tscn")

var papers: Array[Paper] = []

func _ready():
	spawn_papers()


func spawn_papers():
	var container = Node2D.new()
	container.name = "PaperContainer"
	add_child(container)
	
	print("Spawning ", paper_count, " papers")
	
	for i in range(paper_count):
		var paper = paper_scene.instantiate()
		#var paper = Paper.new()
		#
		#if paper_textures.size() > 0:
			#paper.paper_texture = paper_textures[i % paper_textures.size()]
		
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
		papers.append(paper)
		
		print("Paper ", i, " added at position: ", paper.position)
