class_name DataLoader
extends RefCounted

static func load_data(json_path: String, external_data: Dictionary = {}) -> Dictionary:
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
			var obj = GeneratedDataClasses.StoryGroup.new(entry)
			var errors = obj.validate()
			if errors.size() > 0:
				push_warning("Validation errors: " + str(errors))
			storygroup_list.append(obj)
			if entry.has("group_id"):
				var id_val = entry["group_id"]
				if id_val is String:
					storygroup_by_id[id_val] = obj
				else:
					storygroup_by_id[int(id_val)] = obj
		result["StoryGroup"] = storygroup_list
		all_objects["StoryGroup"] = storygroup_by_id

	if data.has("Story"):
		var story_list: Array[GeneratedDataClasses.Story] = []
		var story_by_id = {}
		for entry in data["Story"]:
			var obj = GeneratedDataClasses.Story.new(entry)
			var errors = obj.validate()
			if errors.size() > 0:
				push_warning("Validation errors: " + str(errors))
			story_list.append(obj)
			if entry.has("story_id"):
				var id_val = entry["story_id"]
				if id_val is String:
					story_by_id[id_val] = obj
				else:
					story_by_id[int(id_val)] = obj
		result["Story"] = story_list
		all_objects["Story"] = story_by_id

	if data.has("MediaPostGroup"):
		var mediapostgroup_list: Array[GeneratedDataClasses.MediaPostGroup] = []
		var mediapostgroup_by_id = {}
		for entry in data["MediaPostGroup"]:
			var obj = GeneratedDataClasses.MediaPostGroup.new(entry)
			var errors = obj.validate()
			if errors.size() > 0:
				push_warning("Validation errors: " + str(errors))
			mediapostgroup_list.append(obj)
			if entry.has("group_id"):
				var id_val = entry["group_id"]
				if id_val is String:
					mediapostgroup_by_id[id_val] = obj
				else:
					mediapostgroup_by_id[int(id_val)] = obj
		result["MediaPostGroup"] = mediapostgroup_list
		all_objects["MediaPostGroup"] = mediapostgroup_by_id

	if data.has("StoryPosts"):
		var storyposts_list: Array[GeneratedDataClasses.StoryPosts] = []
		var storyposts_by_id = {}
		for entry in data["StoryPosts"]:
			var obj = GeneratedDataClasses.StoryPosts.new(entry)
			var errors = obj.validate()
			if errors.size() > 0:
				push_warning("Validation errors: " + str(errors))
			storyposts_list.append(obj)
			if entry.has("story_id"):
				var id_val = entry["story_id"]
				if id_val is String:
					storyposts_by_id[id_val] = obj
				else:
					storyposts_by_id[int(id_val)] = obj
		result["StoryPosts"] = storyposts_list
		all_objects["StoryPosts"] = storyposts_by_id

	if data.has("SocialMediaPost"):
		var socialmediapost_list: Array[GeneratedDataClasses.SocialMediaPost] = []
		var socialmediapost_by_id = {}
		for entry in data["SocialMediaPost"]:
			var obj = GeneratedDataClasses.SocialMediaPost.new(entry)
			var errors = obj.validate()
			if errors.size() > 0:
				push_warning("Validation errors: " + str(errors))
			socialmediapost_list.append(obj)
			if entry.has("post_id"):
				var id_val = entry["post_id"]
				if id_val is String:
					socialmediapost_by_id[id_val] = obj
				else:
					socialmediapost_by_id[int(id_val)] = obj
		result["SocialMediaPost"] = socialmediapost_list
		all_objects["SocialMediaPost"] = socialmediapost_by_id

	var ref_errors = _validate_references(all_objects, external_data)
	if ref_errors.size() > 0:
		for err in ref_errors:
			push_warning("Reference error: " + err)

	return result

static func _validate_references(all_objects: Dictionary, external_data: Dictionary) -> Array[String]:
	var errors: Array[String] = []

	# StoryGroup external references
	if all_objects.has("StoryGroup"):
		for obj in all_objects["StoryGroup"].values():
			# stories -> Story.story_id (external)
			if obj.stories != null:
				for ref_id in obj.stories:
					if not external_data.get("Story", {}).has(ref_id):
						errors.append("StoryGroup." + str(obj.group_id) + ".stories references missing external Story." + str(ref_id))

	# MediaPostGroup external references
	if all_objects.has("MediaPostGroup"):
		for obj in all_objects["MediaPostGroup"].values():
			# group_id -> StoryGroup.group_id (external)
			if obj.group_id != null:
				if not external_data.get("StoryGroup", {}).has(obj.group_id):
					errors.append("MediaPostGroup." + str(obj.group_id) + ".group_id references missing external StoryGroup." + str(obj.group_id))
			# story_posts -> StoryPosts.story_id (external)
			if obj.story_posts != null:
				for ref_id in obj.story_posts:
					if not external_data.get("StoryPosts", {}).has(ref_id):
						errors.append("MediaPostGroup." + str(obj.group_id) + ".story_posts references missing external StoryPosts." + str(ref_id))

	# StoryPosts external references
	if all_objects.has("StoryPosts"):
		for obj in all_objects["StoryPosts"].values():
			# story_id -> Story.story_id (external)
			if obj.story_id != null:
				if not external_data.get("Story", {}).has(obj.story_id):
					errors.append("StoryPosts." + str(obj.story_id) + ".story_id references missing external Story." + str(obj.story_id))
			# posts -> SocialMediaPost.post_id (external)
			if obj.posts != null:
				for ref_id in obj.posts:
					if not external_data.get("SocialMediaPost", {}).has(ref_id):
						errors.append("StoryPosts." + str(obj.story_id) + ".posts references missing external SocialMediaPost." + str(ref_id))

	return errors

static func load_multiple_files(file_paths: Array[String]) -> Dictionary:
	var combined = {}
	var external_lookup = {}

	for path in file_paths:
		var data = load_data(path, external_lookup)
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

	return combined