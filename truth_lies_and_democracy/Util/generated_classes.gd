class_name GeneratedDataClasses
extends RefCounted


static func _parse_int(value: Variant, field_name: String) -> int:
	if value is int:
		return value
	if value is float:
		return int(value)
	if value is String:
		if value.is_valid_int():
			return value.to_int()
		else:
			push_warning(field_name + ": Cannot convert '" + value + "' to int")
			return 0
	push_warning(field_name + ": Unexpected type for int conversion")
	return 0

static func _parse_float(value: Variant, field_name: String) -> float:
	if value is float:
		return value
	if value is int:
		return float(value)
	if value is String:
		if value.is_valid_float():
			return value.to_float()
		else:
			push_warning(field_name + ": Cannot convert '" + value + "' to float")
			return 0.0
	push_warning(field_name + ": Unexpected type for float conversion")
	return 0.0

static func _parse_bool(value: Variant, field_name: String) -> bool:
	if value is bool:
		return value
	if value is int:
		return value != 0
	if value is String:
		var lower = value.to_lower().strip_edges()
		return lower in ["true", "1", "yes", "y"]
	push_warning(field_name + ": Unexpected type for bool conversion")
	return false

static func _parse_int_array(value: Variant, field_name: String) -> Array[int]:
	var result: Array[int] = []
	if value is Array:
		for item in value:
			result.append(_parse_int(item, field_name + "[]"))
	elif value is String:
		var parts = value.split(",", false)
		for part in parts:
			var trimmed = part.strip_edges()
			if not trimmed.is_empty():
				result.append(_parse_int(trimmed, field_name + "[]"))
	else:
		push_warning(field_name + ": Expected Array or String for array conversion")
	return result

static func _parse_float_array(value: Variant, field_name: String) -> Array[float]:
	var result: Array[float] = []
	if value is Array:
		for item in value:
			result.append(_parse_float(item, field_name + "[]"))
	elif value is String:
		var parts = value.split(",", false)
		for part in parts:
			var trimmed = part.strip_edges()
			if not trimmed.is_empty():
				result.append(_parse_float(trimmed, field_name + "[]"))
	else:
		push_warning(field_name + ": Expected Array or String for array conversion")
	return result

static func _parse_string_array(value: Variant, field_name: String) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			result.append(item)
	elif value is String:
		var parts = value.split(",", false)
		for part in parts:
			var trimmed = part.strip_edges()
			if not trimmed.is_empty():
				result.append(trimmed)
	else:
		push_warning(field_name + ": Expected Array or String for array conversion")
	return result

class StoryGroup:
	var group_id: int
	var stories: Array[int]
	
	var stories_resolved: Array[GeneratedDataClasses.Story] = []
	
	func _init(data: Dictionary = {}) -> void:
		var raw_group_id = data.get("group_id")
		if raw_group_id != null:
			group_id = GeneratedDataClasses._parse_int(raw_group_id, "StoryGroup.group_id")
		else:
			group_id = 0
		
		var raw_stories = data.get("stories")
		if raw_stories != null:
			stories = GeneratedDataClasses._parse_int_array(raw_stories, "StoryGroup.stories")
		else:
			stories = []

	
	
	func validate() -> Array[String]:
		var errors: Array[String] = []
		
		if stories == null or stories.is_empty():
			errors.append("StoryGroup.stories is required")

		return errors
	

class Story:
	var story_id: int
	var news_headline: String
	var news_content: String
	var news_fake: bool
	
	
	func _init(data: Dictionary = {}) -> void:
		var raw_story_id = data.get("story_id")
		if raw_story_id != null:
			story_id = GeneratedDataClasses._parse_int(raw_story_id, "Story.story_id")
		else:
			story_id = 0
		
		var raw_news_headline = data.get("news_headline")
		if raw_news_headline != null:
			news_headline = raw_news_headline
		else:
			news_headline = ""
		
		var raw_news_content = data.get("news_content")
		if raw_news_content != null:
			news_content = raw_news_content
		else:
			news_content = ""
		
		var raw_news_fake = data.get("news_fake")
		if raw_news_fake != null:
			news_fake = GeneratedDataClasses._parse_bool(raw_news_fake, "Story.news_fake")
		else:
			news_fake = false
		
	
	
	func validate() -> Array[String]:
		var errors: Array[String] = []
		
		if news_headline == null or news_headline.is_empty():
			errors.append("Story.news_headline is required")
		if news_headline != null and news_headline.length() > 200:
			errors.append("Story.news_headline exceeds max length of 200")

		if news_content == null or news_content.is_empty():
			errors.append("Story.news_content is required")
		if news_content != null and news_content.length() > 1000:
			errors.append("Story.news_content exceeds max length of 1000")

		return errors
	

class MediaPostGroup:
	var group_id: int
	var story_posts: Array[int]
	
	var group_id_resolved: GeneratedDataClasses.StoryGroup
	var story_posts_resolved: Array[GeneratedDataClasses.StoryPosts] = []
	
	func _init(data: Dictionary = {}) -> void:
		var raw_group_id = data.get("group_id")
		if raw_group_id != null:
			group_id = GeneratedDataClasses._parse_int(raw_group_id, "MediaPostGroup.group_id")
		else:
			group_id = 0
		
		var raw_story_posts = data.get("story_posts")
		if raw_story_posts != null:
			story_posts = GeneratedDataClasses._parse_int_array(raw_story_posts, "MediaPostGroup.story_posts")
		else:
			story_posts = []

	
	
	func validate() -> Array[String]:
		var errors: Array[String] = []
		
		if story_posts == null or story_posts.is_empty():
			errors.append("MediaPostGroup.story_posts is required")

		return errors
	

class StoryPosts:
	var story_id: int
	var posts: Array[int]
	
	var story_id_resolved: GeneratedDataClasses.Story
	var posts_resolved: Array[GeneratedDataClasses.SocialMediaPost] = []
	
	func _init(data: Dictionary = {}) -> void:
		var raw_story_id = data.get("story_id")
		if raw_story_id != null:
			story_id = GeneratedDataClasses._parse_int(raw_story_id, "StoryPosts.story_id")
		else:
			story_id = 0
		
		var raw_posts = data.get("posts")
		if raw_posts != null:
			posts = GeneratedDataClasses._parse_int_array(raw_posts, "StoryPosts.posts")
		else:
			posts = []

	
	
	func validate() -> Array[String]:
		var errors: Array[String] = []
		
		if posts == null or posts.is_empty():
			errors.append("StoryPosts.posts is required")

		return errors
	

class SocialMediaPost:
	var post_id: int
	var user_name: String
	var content_text: String
	
	
	func _init(data: Dictionary = {}) -> void:
		var raw_post_id = data.get("post_id")
		if raw_post_id != null:
			post_id = GeneratedDataClasses._parse_int(raw_post_id, "SocialMediaPost.post_id")
		else:
			post_id = 0
		
		var raw_user_name = data.get("user_name")
		if raw_user_name != null:
			user_name = raw_user_name
		else:
			user_name = ""
		
		var raw_content_text = data.get("content_text")
		if raw_content_text != null:
			content_text = raw_content_text
		else:
			content_text = ""
		
	
	
	func validate() -> Array[String]:
		var errors: Array[String] = []
		
		if user_name == null or user_name.is_empty():
			errors.append("SocialMediaPost.user_name is required")
		if user_name != null and user_name.length() > 50:
			errors.append("SocialMediaPost.user_name exceeds max length of 50")

		if content_text == null or content_text.is_empty():
			errors.append("SocialMediaPost.content_text is required")
		if content_text != null and content_text.length() > 500:
			errors.append("SocialMediaPost.content_text exceeds max length of 500")

		return errors
	

