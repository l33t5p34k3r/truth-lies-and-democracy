extends Node


enum PARTY {
	PARTY1, PARTY2, PARTY3, PARTY4
}

const PARTIES:Array[String] = [
	"PARTY1",
	"PARTY2",
	"PARTY3",
	"PARTY4"
]

enum MOUSE_MODE { NONE, DRAGGING, DRAGGING_ACTIVE, DRAWING, POINTING}
const MOUSE_ICONS := {
	MOUSE_MODE.NONE: preload("res://Assets/textures/Cursor/Outline/Default/cursor_none.png"),
	MOUSE_MODE.DRAGGING: preload("res://Assets/textures/Cursor/Outline/Default/hand_open.png"),
	MOUSE_MODE.DRAGGING_ACTIVE: preload("res://Assets/textures/Cursor/Outline/Default/hand_closed.png"),
	MOUSE_MODE.DRAWING: preload("res://Assets/textures/Cursor/Outline/Default/drawing_pencil.png"),
	MOUSE_MODE.POINTING: preload("res://Assets/textures/Cursor/Outline/Default/hand_point.png")
}
const MOUSE_HOTSPOTS := {
	MOUSE_MODE.NONE: Vector2(9,6),
	MOUSE_MODE.DRAGGING: Vector2(7,7),
	MOUSE_MODE.DRAGGING_ACTIVE: Vector2(7,7),
	MOUSE_MODE.DRAWING: Vector2(7,7),
	MOUSE_MODE.POINTING: Vector2(7,5)
}

var currently_selected_paper:int = -1

var current_round = 1

var money:int = 1000 :
	get:
		return money
	set(value):
		if value > money:
			total_money_earned += (value - money)
		money = value

var current_cost_per_round:int = 5
var current_onlyfans_money_per_round:int = 1

var report_accuracy:float = 50.0

var partisan_trust:Dictionary[PARTY, float] = {
	PARTY.PARTY1: 50.0,
	PARTY.PARTY2: 50.0,
	PARTY.PARTY3: 50.0,
	PARTY.PARTY4: 50.0
}
var partisan_funding:Dictionary[PARTY, int] = {
	PARTY.PARTY1: 60,
	PARTY.PARTY2: 90,
	PARTY.PARTY3: 500,
	PARTY.PARTY4: 140
}

enum STATS {
	CURRENT_MONEY, TOTAL_MONEY_EARNED, EXPENSES_PER_ROUND, FUNDING_FROM_PARTIES, FAKE_NEWS_PUBLISHED, USELESS_STATS_TRACKED
}
# TODO: substats (some stats are per party)
var stat_display_name :Dictionary[STATS, String] = {
	STATS.CURRENT_MONEY: "Current Moneys",
	STATS.TOTAL_MONEY_EARNED: "Total amount of moneys earned",
	STATS.EXPENSES_PER_ROUND: "Money leaving each round",
	STATS.FUNDING_FROM_PARTIES: "Moneys provided by parties",
	STATS.FAKE_NEWS_PUBLISHED: "Fake news you have personally published",
	STATS.USELESS_STATS_TRACKED: "The number of stats we have tracked for no reason."
}

# TODO: stat description (e.g. as a popup-tooltip)

# stat_key -> stat name
func get_stat_names_pretty() -> Dictionary[STATS, String]:
	return stat_display_name

# stat_key -> stat value as str
func get_stat_values_pretty() -> Dictionary[STATS, String]:
	var current_stats :Dictionary[STATS, String] = {}

	current_stats[STATS.CURRENT_MONEY] = str(money)
	current_stats[STATS.TOTAL_MONEY_EARNED] = str(total_money_earned)
	current_stats[STATS.EXPENSES_PER_ROUND] = str(round_expenses())
	current_stats[STATS.FUNDING_FROM_PARTIES] = str(funding_from_parties())
	current_stats[STATS.FAKE_NEWS_PUBLISHED] = str(fake_news_published)
	current_stats[STATS.USELESS_STATS_TRACKED] = str(STATS.size())

	for key in STATS.values():
		if not key in current_stats:
			push_error("Missing key from current_stats: ", key)

	return current_stats


func round_expenses() -> int:
	var total_expenses:int = 0
	total_expenses += current_cost_per_round
	return total_expenses
	
func round_income() -> int:
	var total_income:int = 0
	total_income += current_onlyfans_money_per_round
	total_income += funding_from_parties()
	return total_income

func funding_from_parties() -> int:
	var total_funding:int = 0
	for party in partisan_trust:
		total_funding += floor((partisan_trust[party] / 100.0) * partisan_funding[party])
	return total_funding


func set_mouse_cursor(variant:MOUSE_MODE):
	# TODO: set it up to use the actual built-in mouse types? (i.e. not just arrow)
	Input.set_custom_mouse_cursor(MOUSE_ICONS[variant], Input.CursorShape.CURSOR_ARROW, MOUSE_HOTSPOTS[variant])

func _enter_tree() -> void:
	DataLoader.load_multiple_files(["res://Assets/papers/data.json"])
	set_mouse_cursor(MOUSE_MODE.NONE)


# bunch of stats
var fake_news_published:int = 0
var favorable_stories:Dictionary[Manager.PARTY, int] = {
	Manager.PARTY.PARTY1:0,
	Manager.PARTY.PARTY2:0,
	Manager.PARTY.PARTY3:0,
	Manager.PARTY.PARTY4:0,
}

var money_spent_on_detection_tools:int = 0

var times_fallen_for_fake_images:int = 0

var total_money_earned:int = 0

# TODO: split UI stuff (mouse etc) into a different singleton class
# TODO: split scene stuff into a different singleton?

enum SCENE {
	DESKTOP,
	SOCIALMEDIA,
	REVIEW
}

const scene_resource :Dictionary[SCENE, Resource]= {
	SCENE.DESKTOP: preload("res://Scenes/paper_playground.tscn"),
	SCENE.SOCIALMEDIA: preload("res://Scenes/SocialMedia/SocialMedia.tscn"),
	SCENE.REVIEW: preload("res://Scenes/report/ProgressReview.tscn")
}


func load_compressed_text(file_path: String) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: " + file_path)
		return ""

	var compressed_data = file.get_buffer(file.get_length())
	file.close()

	var decompressed_data = compressed_data.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	if decompressed_data.is_empty():
		push_error("Failed to decompress data")
		return ""
	
	return decompressed_data.get_string_from_utf8()



func change_scene_to(scene:SCENE):
	get_tree().call_group("scene_managers", "switch_scene", scene)
