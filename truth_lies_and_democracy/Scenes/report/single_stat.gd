extends PanelContainer
class_name SingleStatContainer

@onready var stat_name: Label = $MarginContainer/StatsVbox/StatName
@onready var stat_result: Label = $MarginContainer/StatsVbox/StatResult
var text_stat_name: String = ""
var text_stat_result: String = ""

func _ready():
	stat_name.text = text_stat_name
	stat_result.text = text_stat_result
