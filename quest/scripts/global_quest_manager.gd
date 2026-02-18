extends Node

signal quest_updated(q)

const QUEST_DATA_LOCATION: String = "res://quest/"

var quests: Array[Quest] = []

# Active quests being tracked by the UI
var current_quests: Array = []

# All quests categorized by stage
var all_quests: Dictionary = {
	"prelim": [
		{ "title": "apple", "is_complete": false, "completed_steps": [] },
		{ "title": "Long Quest", "is_complete": false, "completed_steps": [] },
		{ "title": "Short Quest", "is_complete": false, "completed_steps": [] }
	],
	"midterm": [
		{ "title": "Banana Quest", "is_complete": false, "completed_steps": [] },
		{ "title": "Collect Notes", "is_complete": false, "completed_steps": [] }
	],
	"final": [
		{ "title": "Final Exam Quest", "is_complete": false, "completed_steps": [] },
		{ "title": "Submit Project", "is_complete": false, "completed_steps": [] }
	]
}

func _ready() -> void:
	# Start with prelim quests
	current_quests = all_quests["prelim"].duplicate(true)
	gather_quest_data()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		print("Before:", current_quests)

		# Correct sequentially added steps
		update_quest("Long Quest", "Step 1")
		update_quest("Long Quest", "Step 2")
		update_quest("Long Quest", "Step 3")
		
		# For 'apple', add steps before completing
		update_quest("apple", "Find the Apple")
		update_quest("apple", "Return the apple to NPC")
		update_quest("apple", "", true) 

		print("After:", current_quests)
		print("=======================================")

# --- QUEST DATA LOADING ---
func gather_quest_data() -> void:
	var quest_files = DirAccess.get_files_at(QUEST_DATA_LOCATION)
	quests.clear()
	for q in quest_files:
		var resource = load(QUEST_DATA_LOCATION + "/" + q)
		if resource is Quest:
			quests.append(resource)
	print("Quest count:", quests.size())

# --- QUEST UPDATES ---
func update_quest(_title: String, _step: String = "", _complete: bool = false) -> void:
	var index = get_quest_index_by_title(_title)

	if index == -1:
		var new_quest: Dictionary = {
			"title": _title,
			"is_complete": _complete,
			"completed_steps": []
		}
		if _step != "":
			new_quest["completed_steps"].append(_step.to_lower())
		current_quests.append(new_quest)
		quest_updated.emit(new_quest)
		return

	var q = current_quests[index]

	# Add step only if provided and not already there
	if _step != "":
		var step_lower = _step.to_lower()
		if not q["completed_steps"].has(step_lower):
			q["completed_steps"].append(step_lower)
			print("Step Added:", step_lower, " to ", _title)

	# Mark as complete and handle rewards
	if _complete and not q["is_complete"]:
		q["is_complete"] = true
		var quest_res = find_quest_by_title(_title)
		if quest_res:
			disperse_quest_rewards(quest_res)
	
	quest_updated.emit(q)

func disperse_quest_rewards(_q: Quest) -> void:
	if _q == null: return
	for i in _q.reward_items:
		if has_node("/root/GlobalPlayerManager"):
			PlayerManager.INVENTORY_DATA.add_item(i.item, i.quantity)

# --- SEARCH FUNCTIONS ---
func find_quest(_quest: Quest) -> Dictionary:
	for q in current_quests:
		if q["title"].to_lower() == _quest.title.to_lower():
			return q
	return { "title": "not found", "is_complete": false, "completed_steps": [] }

func find_quest_by_title(_title: String) -> Quest:
	for q in quests:
		if q.title.to_lower() == _title.to_lower():
			return q
	return null

func get_quest_index_by_title(_title: String) -> int:
	for i in range(current_quests.size()):
		if current_quests[i]["title"].to_lower() == _title.to_lower():
			return i
	return -1
