extends PanelContainer
class_name MediaPost

@onready var user_name: Label = %UserName
@onready var post_content: RichTextLabel = %PostContent
# TODO: either load path from json or index into a pre-defined array or so
@onready var user_icon: TextureRect = %UserIcon

@onready var upvote_button: TextureButton = %UpvoteButton
@onready var downvote_button: TextureButton = %DownvoteButton
@onready var button_separator: VBoxContainer = %ButtonSeparator

@onready var margin_container: MarginContainer = $MarginContainer


var text_username:String = "NoName"
var text_content:String = "Missing Content."

func _ready():
	user_name.text = text_username
	post_content.text = text_content


func _on_upvote_button_pressed() -> void:
	if downvote_button.button_pressed:
		downvote_button.button_pressed = false

func _on_downvote_button_pressed() -> void:
	if upvote_button.button_pressed:
		upvote_button.button_pressed = false


func _on_block_button_pressed() -> void:
	var tween = get_tree().create_tween().bind_node(self)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(post_content, "visible_ratio", 0.0, 0.9)
	tween.parallel().tween_property(user_name, "visible_ratio", 0.0, 1.0)
	tween.parallel().tween_property(user_icon, "custom_minimum_size", Vector2(0,0), 1.0)
	tween.parallel().tween_property(%UpvoteButton, "custom_minimum_size", Vector2(0,0), 1.0)
	tween.parallel().tween_property(%DownvoteButton, "custom_minimum_size", Vector2(0,0), 1.0)
	tween.parallel().tween_property(%BlockButton, "custom_minimum_size", Vector2(0,0), 1.0)
	tween.parallel().tween_property(user_name, "theme_override_font_sizes/font_size", 5, 1.0)
	
	margin_container.add_theme_constant_override("margin_bottom",margin_container.get_theme_constant("margin_bottom"))
	margin_container.add_theme_constant_override("margin_top",margin_container.get_theme_constant("margin_top"))
	tween.parallel().tween_property(margin_container, "theme_override_constants/margin_bottom", 0, 0.8)
	tween.parallel().tween_property(margin_container, "theme_override_constants/margin_top", 0, 0.8)
	tween.parallel().tween_property(button_separator, "theme_override_constants/separation", 0, 0.5)
	
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	
	tween.tween_callback(self.queue_free)
