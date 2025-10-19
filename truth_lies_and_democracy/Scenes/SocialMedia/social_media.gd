extends VBoxContainer


@onready var content: VBoxContainer = %Content
const MEDIA_POST = preload("uid://cy85dub7l2p5n")
const STORY_POST = preload("uid://b7037uk7lkt5v")



func _ready() -> void:
	load_posts()
	
func get_stories(group_id:int) -> Array:
	var file = FileAccess.open("res://Assets/papers/papers.json", FileAccess.READ).get_as_text()
	var json = JSON.new()
	json.parse(file)
	var papers = json.data
	var container = Node2D.new()
	container.name = "PaperContainer"
	add_child(container)
	
	for paper_set:Dictionary in papers:
		if paper_set["group_id"] != str(group_id):
			continue
			
		return paper_set["stories"]
		
	return []
			
	
func load_posts():
	var data = DataLoader.load_data("res://Assets/papers/data.json")
	var media_post_group: Array[GeneratedDataClasses.MediaPostGroup] = data["MediaPostGroup"]

	for post_group in media_post_group:
		for story_post in post_group.story_posts_resolved:
			
			var new_story_header :StoryPost = STORY_POST.instantiate()
			new_story_header.text_story = story_post.story_id_resolved.news_headline
			content.add_child(new_story_header)
			
			for post in story_post.posts_resolved:
				var new_post_node :MediaPost = MEDIA_POST.instantiate()
				
				new_post_node.text_username = post["user_name"]
				print(post["content_text"])
				new_post_node.text_content = post["content_text"]
				print(new_post_node.text_content)
				
				content.add_child(new_post_node)
				
	
	
	
	#var file := FileAccess.open("res://Assets/papers/media_posts.json", FileAccess.READ).get_as_text()
	#var json = JSON.new()
	#var error := json.parse(file)
	#if error != OK:
		#push_error("JSON Parse Error: ", json.get_error_message(), " in ", file, " at line ", json.get_error_line())
		#
	#var posts:Array = json.data
	#var related_stories := get_stories(Manager.current_round)
	#for post_set:Dictionary in posts:
		#if post_set["group_id"] != str(Manager.current_round):
			#continue
			#
		#var ordered_post_set :Array = post_set["posts"]
		#ordered_post_set.shuffle()
		#for posts_per_story:Dictionary in ordered_post_set:
			#
			## grab relevant headline
			#var target_story_id = posts_per_story["story_id"]
			#var headline_text := "Missing"
			#for story in related_stories:
				#if story["story_id"] == str(target_story_id):
					#headline_text = story["news_headline"]
			#
			#var new_story_header :StoryPost = STORY_POST.instantiate()
			#new_story_header.text_story = headline_text
			#content.add_child(new_story_header)
					#
			#var posts_to_create :Array = posts_per_story["posts"]
			#posts_to_create.shuffle()
			#for post:Dictionary in posts_to_create:
				#var new_post_node :MediaPost = MEDIA_POST.instantiate()
				#
				#new_post_node.text_username = post["user_name"]
				#new_post_node.text_content = post["content_text"]
				#
				#content.add_child(new_post_node)
	#
