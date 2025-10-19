# Desktop.gd - Main desktop scene script
extends Node2D

@export var paper_textures: Array[Texture2D]

@onready var paper_scene = preload("res://Scenes/paper.tscn")

@onready var confirm_button: Button = $CanvasLayer/Control/confirm2Button
@onready var first_confirm_button: Button = $CanvasLayer/Control/confirm1Button


var paper_array: Array[Paper] = []
var approved_paper: Array[Paper] = []

var papers_need_to_be_signed: Array[Paper] = []

var paper_container = Node2D.new()




func _ready():
	%SignPrompt.visible = false
	confirm_button.visible = false
	first_confirm_button.visible = false
	load_papers()


func load_papers():
	spawn_papers(DataLoader.StoryGroup_array)
	
func spawn_papers(papers : Array[GeneratedDataClasses.StoryGroup]):
	var container = Node2D.new()
	container.name = "PaperContainer"
	add_child(container)
	
	for paper_set:GeneratedDataClasses.StoryGroup in papers:
		if paper_set.group_id != Manager.current_round:
			continue
			
		for story:GeneratedDataClasses.Story in paper_set.stories_resolved:
		
			var paper :Paper= paper_scene.instantiate()
			
			paper.paper_headline = story.news_headline
			paper.paper_content = story.news_content
			paper.paper_is_fake = story.news_fake
			
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
	if not first_confirm_button.visible and not confirm_button.visible:
		first_confirm_button.visible = true

#

func _on_confirm_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/report/ProgressReview.tscn")


func _on_first_confirm_button_pressed() -> void:
	%Stamp.is_enabled = false
	%Stamp.visible = false
	papers_need_to_be_signed.clear()
	for paper in paper_array:
		if paper.is_stamped:
			paper.enable_drawing()
			papers_need_to_be_signed.append(paper)
	
	%SignPrompt.visible = true
	%DocuSignTimer.start()
	
	first_confirm_button.visible = false	




# slight delay on check
func _on_docu_sign_timer_timeout() -> void:
	var all_relevant_papers_signed := true
	for paper in papers_need_to_be_signed:
		if not paper.is_signed:
			all_relevant_papers_signed = false
	
	if all_relevant_papers_signed:
		confirm_button.visible = true
		%DocuSignTimer.stop()


func _on_escape_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/SocialMedia/SocialMedia.tscn")
