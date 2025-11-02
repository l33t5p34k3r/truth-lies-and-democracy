# Desktop.gd - Main desktop scene script
extends Node2D

@export var paper_textures: Array[Texture2D]

@onready var paper_scene = preload("res://Scenes/paper.tscn")

@onready var confirm_button: Button = $CanvasLayer/Control/confirm2Button
@onready var first_confirm_button: Button = $CanvasLayer/Control/confirm1Button
@onready var button_control: Control = $CanvasLayer/Control
@onready var draw_button: Button = $CanvasLayer/Control/Draw
@onready var stamp_button: Button = $CanvasLayer/Control/StampButton
@onready var stamp: Stamp = %Stamp


var paper_array: Array[Paper] = []
var approved_paper: Array[Paper] = []

var papers_need_to_be_signed: Array[Paper] = []
var paper_container = Node2D.new()


var mouse_mode:Manager.MOUSE_MODE = Manager.MOUSE_MODE.DRAGGING




func _ready():
	set_mouse_cursor()
	%SignPrompt.visible = false
	confirm_button.visible = false
	first_confirm_button.visible = false
	load_papers()
	
	# connect control nodes
	cursor_connect_children(button_control)


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

func _on_drag_started():
	Manager.set_mouse_cursor(Manager.MOUSE_MODE.DRAGGING)


func _on_drag_stopped():
	Manager.set_mouse_cursor(Manager.MOUSE_MODE.DRAGGING_ACTIVE)
	

func _on_confirm_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/report/ProgressReview.tscn")


func _on_first_confirm_button_pressed() -> void:
	%Stamp.is_enabled = false
	%Stamp.visible = false
	%StampButton.visible = false
	papers_need_to_be_signed.clear()
	get_tree().call_group("draw_components", "reset_sign_stats")
	for paper in paper_array:
		if paper.is_stamped:
			paper.enable_document_signing()
			papers_need_to_be_signed.append(paper)
	
	%SignPrompt.visible = true
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_callback(add_sign_hint).set_delay(15)
	%DocuSignTimer.start()
	
	first_confirm_button.visible = false	

func add_sign_hint():
	if all_stamped_papers_signed():
		return
	%SignPromptLabel.text += "\nHint: Make sure it's a proper signature, not just a small dot!"

func all_stamped_papers_signed() -> bool:
	var all_relevant_papers_signed := true
	var draw_components:Array[DrawComponent]
	draw_components.assign(get_tree().get_nodes_in_group("draw_components"))
	for component in draw_components:
		if not component.is_signed and component.get_parent() in papers_need_to_be_signed:
			all_relevant_papers_signed = false
	return all_relevant_papers_signed

# slight delay on check
func _on_docu_sign_timer_timeout() -> void:
	if all_stamped_papers_signed():
		confirm_button.visible = true
		%DocuSignTimer.stop()


func _on_escape_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/SocialMedia/SocialMedia.tscn")


#TODO: this could be moved into a singleton or so
func cursor_connect_children(node: Node):
	if node is BaseButton:
		node.mouse_entered.connect(_on_control_mouse_entered)
		node.mouse_exited.connect(_on_control_mouse_exited)
	
	for child in node.get_children():
		cursor_connect_children(child)

func _on_control_mouse_entered():
	Manager.set_mouse_cursor(Manager.MOUSE_MODE.POINTING)

func _on_control_mouse_exited():
	set_mouse_cursor()

	

func _on_draw_toggled(toggled_on: bool) -> void:
	if toggled_on:
		mouse_mode = Manager.MOUSE_MODE.DRAWING
		on_drag_allow_change(false)
		on_drawing_allow_change(true)
		draw_button.text = "Disable Drawing"
	else:
		mouse_mode = Manager.MOUSE_MODE.DRAGGING
		on_drag_allow_change(true)
		on_drawing_allow_change(false)
		draw_button.text = "Enable Drawing"
	set_mouse_cursor()

func on_drawing_allow_change(new_drawing_enabled:bool) -> void:
	get_tree().call_group("draw_components", "on_draw_allow_change", new_drawing_enabled)
		
func on_drag_allow_change(new_drag_enabled:bool) -> void:
	get_tree().call_group("drag_components", "on_drag_allow_change", new_drag_enabled)

# TODO: custom mouse cursor per scene? or can we more generically work with interactables and UI?
func set_mouse_cursor():
	Manager.set_mouse_cursor(mouse_mode)


func _on_stamp_pressed() -> void:
	stamp.on_stamp_pressed()
