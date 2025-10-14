extends PanelContainer
class_name StoryPost

@onready var story_headline: Label = %StoryHeadline

var text_story:String = "None"

func _ready():
	story_headline.text = text_story
