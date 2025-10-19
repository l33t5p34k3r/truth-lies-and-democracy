extends VBoxContainer


@onready var content: VBoxContainer = %Content
const MEDIA_POST = preload("uid://cy85dub7l2p5n")
const STORY_POST = preload("uid://b7037uk7lkt5v")



func _ready() -> void:
	load_posts()
			
	
func load_posts():
	for post_group in DataLoader.MediaPostGroup_array:
		for story_post in post_group.story_posts_resolved:
			
			var new_story_header :StoryPost = STORY_POST.instantiate()
			new_story_header.text_story = story_post.story_id_resolved.news_headline
			content.add_child(new_story_header)
			
			for post in story_post.posts_resolved:
				var new_post_node :MediaPost = MEDIA_POST.instantiate()
				
				new_post_node.text_username = post["user_name"]
				new_post_node.text_content = post["content_text"]
				
				content.add_child(new_post_node)
				
	
	
