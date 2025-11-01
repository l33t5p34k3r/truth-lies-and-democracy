extends VBoxContainer


@onready var content: VBoxContainer = %Content
const MEDIA_POST = preload("uid://cy85dub7l2p5n")
const STORY_POST = preload("uid://b7037uk7lkt5v")



func _ready() -> void:
	Manager.set_mouse_cursor(Manager.MOUSE_MODE.NONE)
	load_posts()
	cursor_connect_children(self)
	
func load_posts():
	var active_stories:Array[int] = []
	for story_group in DataLoader.StoryGroup_array:
		if story_group.group_id == Manager.current_round:
			active_stories = story_group.stories
	for post_group in DataLoader.MediaPostGroup_array:
		for story_post in post_group.story_posts_resolved:
			if not story_post.story_id in active_stories:
				continue
			
			var new_story_header :StoryPost = STORY_POST.instantiate()
			new_story_header.text_story = story_post.story_id_resolved.news_headline
			content.add_child(new_story_header)
			
			for post in story_post.posts_resolved:
				var new_post_node :MediaPost = MEDIA_POST.instantiate()
				
				new_post_node.text_username = post.user_name
				new_post_node.text_content = post.content_text
				
				content.add_child(new_post_node)
				
	
	


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/paper_playground.tscn")


func cursor_connect_children(node: Node):
	if node is BaseButton:
		node.mouse_entered.connect(_on_control_mouse_entered)
		node.mouse_exited.connect(_on_control_mouse_exited)
	
	for child in node.get_children():
		cursor_connect_children(child)

func _on_control_mouse_entered():
	Manager.set_mouse_cursor(Manager.MOUSE_MODE.POINTING)

func _on_control_mouse_exited():
	Manager.set_mouse_cursor(Manager.MOUSE_MODE.NONE)
