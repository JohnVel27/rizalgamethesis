extends Node

signal quest_updated(q)

const QUEST_DATA_LOCATION: String = "res://quest/"

var quests: Array[Quest] = []
var current_quests: Array = []

var all_quests: Dictionary = {
	"prelim": [
		{ "title": "Story of the Moth", "is_complete": false, "completed_steps": [] }
	],
	"midterm": [],
	"final": []
}

func _ready() -> void:
	# Load preliminary quests into the active tracking list
	current_quests = all_quests["prelim"].duplicate(true)
	gather_quest_data()
	
func check_location_completion() -> void:
	var current_scene_path = get_tree().current_scene.scene_file_path
	
	# Check if player is in the Rizal Living Room
	if current_scene_path == "res://levels/prelim/1/livingroomrizal.tscn":
		update_quest("Story of the Moth", "Travel to the Rizal House.", false)
		print("Location reached: Rizal Home")

func gather_quest_data() -> void:
	if not DirAccess.dir_exists_absolute(QUEST_DATA_LOCATION):
		return
	var quest_files = DirAccess.get_files_at(QUEST_DATA_LOCATION)
	quests.clear()
	for q in quest_files:
		if q.ends_with(".tres"):
			var resource = load(QUEST_DATA_LOCATION + "/" + q)
			if resource is Quest:
				quests.append(resource)

func update_quest(_title: String, _step: String = "", _complete: bool = false) -> void:
	var index = get_quest_index_by_title(_title)
	var sanitized_step = _step.strip_edges().to_lower()

	# If quest isn't in current_quests, add it
	if index == -1:
		var new_quest: Dictionary = { 
			"title": _title, 
			"is_complete": _complete, 
			"completed_steps": [] 
		}
		if sanitized_step != "": new_quest["completed_steps"].append(sanitized_step)
		current_quests.append(new_quest)
		if _complete: _process_rewards(_title)
		quest_updated.emit(new_quest)
		return

	var q = current_quests[index]

	# Add step if provided
	if sanitized_step != "" and not q["completed_steps"].has(sanitized_step):
		q["completed_steps"].append(sanitized_step)

	# Mark complete and give rewards
	if _complete and not q["is_complete"]:
		q["is_complete"] = true
		_process_rewards(_title)
	
	quest_updated.emit(q)
	print("Quest Log Updated: ", _title, " | Complete: ", q["is_complete"])

func _process_rewards(_title: String) -> void:
	var quest_res = find_quest_by_title(_title)
	if quest_res:
		disperse_quest_rewards(quest_res)

func disperse_quest_rewards(_q: Quest) -> void:
	for reward in _q.reward_items:
		# Ensure the reward object and item reference are valid
		if reward and reward.item != null:
			if has_node("/root/PlayerManager"):
				PlayerManager.INVENTORY_DATA.add_item(reward.item, reward.quantity)
				print("Reward Received: ", reward.item.name)

func find_quest_by_title(_title: String) -> Quest:
	for q in quests:
		if q.title.to_lower() == _title.to_lower(): return q
	return null

func get_quest_index_by_title(_title: String) -> int:
	for i in range(current_quests.size()):
		if current_quests[i]["title"].to_lower() == _title.to_lower(): return i
	return -1
	
# Add this to your QuestManager.gd script
func find_quest(_quest: Quest) -> Dictionary:
	for q in current_quests:
		if q["title"].to_lower() == _quest.title.to_lower():
			return q
	# Return a default empty quest structure if not found
	return { "title": "not found", "is_complete": false, "completed_steps": [] }
