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

var currently_selected_paper:int = -1

var money:int = 1000 :
	get:
		return money
	set(value):
		if value > money:
			total_money_earned += (value - money)
		money = value

var current_cost_per_round:int = 5

var report_accuracy:float = 50.0

var partisan_trust:Dictionary[PARTY, float] = {
	PARTY.PARTY1: 50.0,
	PARTY.PARTY2: 50.0,
	PARTY.PARTY3: 50.0,
	PARTY.PARTY4: 50.0
}





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
