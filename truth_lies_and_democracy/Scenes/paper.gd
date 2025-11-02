class_name Paper
extends RigidBody2D

@export var paper_texture: Texture2D
@export var paper_color: Color = Color.WHITE

signal got_stamped


var paper_headline : String = ""
var paper_content : String = ""
var paper_is_fake : bool = false

@onready var sprite_2d: Sprite2D = $Content/Sprite2D
@onready var text_label: Label = $Content/Control/Label
@onready var text_rich_text_label: RichTextLabel = $Content/Control/RichTextLabel
@onready var draw_collision_shape_2d: CollisionShape2D = $DrawArea/CollisionShape2D
@onready var stamp_mask: Polygon2D = $Content/StampMask
@onready var content: Node2D = $Content


# to make papers slightly drag each other
var overlapping_papers: Array[Paper] = []

var paper_size: Vector2



# checks if paper has been stampged
var is_stamped = false

# something breaks the paper location in this cycle
func _ready():
	
	$Content/SignBox.visible = false
	$Content/SignLabel.visible = false
	
	paper_size = sprite_2d.texture.get_size() * sprite_2d.scale.x
	add_news_content()
	


func add_news_content():
	# Headline
	var headline = text_label
	headline.text = paper_headline

	# Content
	var story_content = text_rich_text_label
	story_content.text = paper_content


func create_headline_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_width_bottom = 1
	style.border_color = Color(0.3, 0.3, 0.3, 0.6)
	return style
	



# override parent function
func is_position_inside_body(pos: Vector2) -> bool:
	var rect = draw_collision_shape_2d.shape.get_rect()
	return rect.has_point(pos - global_position)

#func _process(delta):
	# TODO: move this to highlighting_component
	#content.scale = content.scale.lerp(target_scale, delta * 3)
	

func _on_area_overlap(area):
	var other_paper = area.get_parent()
	if other_paper is Paper and other_paper != self:
		if not overlapping_papers.has(other_paper):
			overlapping_papers.append(other_paper)

func _on_area_exit(area):
	var other_paper = area.get_parent()
	if other_paper is Paper and overlapping_papers.has(other_paper):
		overlapping_papers.erase(other_paper)


func _on_overlap_area_area_entered(area: Area2D) -> void:
	_on_area_overlap(area)


func _on_overlap_area_area_exited(area: Area2D) -> void:
	_on_area_exit(area)
	
func enable_document_signing():
	$Content/SignBox.visible = true
	$Content/SignLabel.visible = true

# does all the stamping
func add_stamp_sprite(texture: Texture2D, stamp_position: Vector2):
	var stamp = Sprite2D.new()
	stamp.texture = texture
	stamp.position = stamp_position
	stamp.rotation = -rotation
	# account for size scaling on hover
	stamp.scale = Vector2(1.0 / content.scale.x, 1.0 / content.scale.y)

	if not is_stamped and self.paper_is_fake:
		Manager.fake_news_published += 1

	stamp_mask.add_child(stamp)
	is_stamped = true
	got_stamped.emit()

# TODO: we need to rework mouse entry/exit events a bit, to account for overlapping papers
# i.e. paper is not topmost when mouse enters, but becomes topmost when mouse exits another paper
# also: paper is topmost, but is no longer topmost when mouse enters another overlapping paper

# TODO: add function into drag_component and make infobox actually a component


		
## TODO: this will not be called if another paper is now highlighted -> build into DragBody2D to make sure only one paper is highlighted at a time
