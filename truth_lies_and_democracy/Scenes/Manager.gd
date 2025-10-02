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
