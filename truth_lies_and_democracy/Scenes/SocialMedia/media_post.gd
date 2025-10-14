extends PanelContainer
class_name MediaPost

@onready var user_name: Label = %UserName
@onready var post_content: RichTextLabel = %PostContent
# TODO: either load path from json or index into a pre-defined array or so
@onready var user_icon: TextureRect = %UserIcon


var text_username:String = "NoName"
var text_content:String = "Missing Content."

func _ready():
	user_name.text = text_username
	post_content.text = text_content
