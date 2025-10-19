class_name DataLoader
extends RefCounted


static var StoryGroup_array:Array[GeneratedDataClasses.StoryGroup] = []
static var Story_array:Array[GeneratedDataClasses.Story] = []
static var MediaPostGroup_array:Array[GeneratedDataClasses.MediaPostGroup] = []
static var StoryPosts_array:Array[GeneratedDataClasses.StoryPosts] = []
static var SocialMediaPost_array:Array[GeneratedDataClasses.SocialMediaPost] = []

static func _load_data(json_path: String, external_data: Dictionary = {}) -> Dictionary:
	""" [WARN] Do not use this function directly! """
	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		push_error("Failed to open: " + json_path)
		return {}

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("JSON parse error: " + json.get_error_message())
		return {}

	var data = json.data
	var result = {}
	var all_objects = {}

	if data.has("StoryGroup"):
		var storygroup_list: Array[GeneratedDataClasses.StoryGroup] = []
		var storygroup_by_id = {}
		for entry in data["StoryGroup"]:
			var obj := GeneratedDataClasses.StoryGroup.new(entry)
			var errors = obj.validate()
			if errors.size() > 0:
				push_warning("Validation errors: " + str(errors))
			storygroup_list.append(obj)
			StoryGroup_array.append(obj)
			if entry.has("group_id"):
				var id_val:int = entry["group_id"]
				storygroup_by_id[id_val] = obj
		result["StoryGroup"] = storygroup_list
		all_objects["StoryGroup"] = storygroup_by_id

	if data.has("Story"):
		var story_list: Array[GeneratedDataClasses.Story] = []
		var story_by_id = {}
		for entry in data["Story"]:
			var obj := GeneratedDataClasses.Story.new(entry)
			var errors = obj.validate()
			if errors.size() > 0:
				push_warning("Validation errors: " + str(errors))
			story_list.append(obj)
			Story_array.append(obj)
			if entry.has("story_id"):
				var id_val:int = entry["story_id"]
				story_by_id[id_val] = obj
		result["Story"] = story_list
		all_objects["Story"] = story_by_id

	if data.has("MediaPostGroup"):
		var mediapostgroup_list: Array[GeneratedDataClasses.MediaPostGroup] = []
		var mediapostgroup_by_id = {}
		for entry in data["MediaPostGroup"]:
			var obj := GeneratedDataClasses.MediaPostGroup.new(entry)
			var errors = obj.validate()
			if errors.size() > 0:
				push_warning("Validation errors: " + str(errors))
			mediapostgroup_list.append(obj)
			MediaPostGroup_array.append(obj)
			if entry.has("group_id"):
				var id_val:int = entry["group_id"]
				mediapostgroup_by_id[id_val] = obj
		result["MediaPostGroup"] = mediapostgroup_list
		all_objects["MediaPostGroup"] = mediapostgroup_by_id

	if data.has("StoryPosts"):
		var storyposts_list: Array[GeneratedDataClasses.StoryPosts] = []
		var storyposts_by_id = {}
		for entry in data["StoryPosts"]:
			var obj := GeneratedDataClasses.StoryPosts.new(entry)
			var errors = obj.validate()
			if errors.size() > 0:
				push_warning("Validation errors: " + str(errors))
			storyposts_list.append(obj)
			StoryPosts_array.append(obj)
			if entry.has("story_id"):
				var id_val:int = entry["story_id"]
				storyposts_by_id[id_val] = obj
		result["StoryPosts"] = storyposts_list
		all_objects["StoryPosts"] = storyposts_by_id

	if data.has("SocialMediaPost"):
		var socialmediapost_list: Array[GeneratedDataClasses.SocialMediaPost] = []
		var socialmediapost_by_id = {}
		for entry in data["SocialMediaPost"]:
			var obj := GeneratedDataClasses.SocialMediaPost.new(entry)
			var errors = obj.validate()
			if errors.size() > 0:
				push_warning("Validation errors: " + str(errors))
			socialmediapost_list.append(obj)
			SocialMediaPost_array.append(obj)
			if entry.has("post_id"):
				var id_val:int = entry["post_id"]
				socialmediapost_by_id[id_val] = obj
		result["SocialMediaPost"] = socialmediapost_list
		all_objects["SocialMediaPost"] = socialmediapost_by_id

	var ref_errors = _validate_references(all_objects, external_data)
	if ref_errors.size() > 0:
		for err in ref_errors:
			push_warning("Reference error: " + err)

	# Resolve all references automatically
	_resolve_all_references(result, all_objects)
	
	return result

static func _resolve_all_references(result: Dictionary, all_objects: Dictionary) -> void:
	"""Automatically resolve all ID references to object references"""

	# Resolve references in StoryGroup
	if result.has("StoryGroup"):
		for obj in result["StoryGroup"]:
			# Resolve stories -> Array[Story]
			if obj.stories != null and all_objects.has("Story"):
				for ref_id in obj.stories:
					var resolved_obj = all_objects["Story"].get(ref_id)
					if resolved_obj:
						obj.stories_resolved.append(resolved_obj)
	
	# Resolve references in MediaPostGroup
	if result.has("MediaPostGroup"):
		for obj in result["MediaPostGroup"]:
			# Resolve group_id -> StoryGroup
			if obj.group_id != null and all_objects.has("StoryGroup"):
				obj.group_id_resolved = all_objects["StoryGroup"].get(obj.group_id)
			# Resolve story_posts -> Array[StoryPosts]
			if obj.story_posts != null and all_objects.has("StoryPosts"):
				for ref_id in obj.story_posts:
					var resolved_obj = all_objects["StoryPosts"].get(ref_id)
					if resolved_obj:
						obj.story_posts_resolved.append(resolved_obj)
	
	# Resolve references in StoryPosts
	if result.has("StoryPosts"):
		for obj in result["StoryPosts"]:
			# Resolve story_id -> Story
			if obj.story_id != null and all_objects.has("Story"):
				obj.story_id_resolved = all_objects["Story"].get(obj.story_id)
			# Resolve posts -> Array[SocialMediaPost]
			if obj.posts != null and all_objects.has("SocialMediaPost"):
				for ref_id in obj.posts:
					var resolved_obj = all_objects["SocialMediaPost"].get(ref_id)
					if resolved_obj:
						obj.posts_resolved.append(resolved_obj)
	

static func _validate_references(all_objects: Dictionary, _external_data: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	
	# StoryGroup internal references
	if all_objects.has("StoryGroup"):
		for obj in all_objects["StoryGroup"].values():
			# stories -> Story.story_id
			if obj.stories != null:
				for ref_id in obj.stories:
					if not all_objects.get("Story", {}).has(ref_id):
						errors.append("StoryGroup." + str(obj.group_id) + ".stories references missing Story." + str(ref_id))
	
	# MediaPostGroup internal references
	if all_objects.has("MediaPostGroup"):
		for obj in all_objects["MediaPostGroup"].values():
			# group_id -> StoryGroup.group_id
			if obj.group_id != null:
				if not all_objects.get("StoryGroup", {}).has(obj.group_id):
					errors.append("MediaPostGroup." + str(obj.group_id) + ".group_id references missing StoryGroup." + str(obj.group_id))
			# story_posts -> StoryPosts.story_id
			if obj.story_posts != null:
				for ref_id in obj.story_posts:
					if not all_objects.get("StoryPosts", {}).has(ref_id):
						errors.append("MediaPostGroup." + str(obj.group_id) + ".story_posts references missing StoryPosts." + str(ref_id))
	
	# StoryPosts internal references
	if all_objects.has("StoryPosts"):
		for obj in all_objects["StoryPosts"].values():
			# story_id -> Story.story_id
			if obj.story_id != null:
				if not all_objects.get("Story", {}).has(obj.story_id):
					errors.append("StoryPosts." + str(obj.story_id) + ".story_id references missing Story." + str(obj.story_id))
			# posts -> SocialMediaPost.post_id
			if obj.posts != null:
				for ref_id in obj.posts:
					if not all_objects.get("SocialMediaPost", {}).has(ref_id):
						errors.append("StoryPosts." + str(obj.story_id) + ".posts references missing SocialMediaPost." + str(ref_id))
	
	return errors

static var full_data:Dictionary = {}

static func load_multiple_files(file_paths: Array[String]) -> void:
	var combined = {}
	var external_lookup = {}
	
	for path in file_paths:
		var data = _load_data(path, external_lookup)
		for type_name in data.keys():
			if not combined.has(type_name):
				combined[type_name] = []
			combined[type_name].append_array(data[type_name])
			
			var lookup = {}
			for obj in data[type_name]:
				if type_name == "StoryGroup" and "group_id" in obj:
					lookup[obj.group_id] = obj
				if type_name == "Story" and "story_id" in obj:
					lookup[obj.story_id] = obj
				if type_name == "MediaPostGroup" and "group_id" in obj:
					lookup[obj.group_id] = obj
				if type_name == "StoryPosts" and "story_id" in obj:
					lookup[obj.story_id] = obj
				if type_name == "SocialMediaPost" and "post_id" in obj:
					lookup[obj.post_id] = obj
			external_lookup[type_name] = lookup
	
	full_data = combined
