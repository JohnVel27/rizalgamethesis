extends CharacterBody2D

var is_near_npc: bool = false

func _ready() -> void:
	# Check if we are already at the house when the scene loads
	if has_node("/root/QuestManager"):
		QuestManager.check_location_completion()
	
	Dialogic.timeline_ended.connect(_on_dialogic_ended)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_near_npc:
		if Dialogic.current_timeline == null:
			var player = get_tree().current_scene.find_child("youngrizal", true, false)
			if player: player.set_physics_process(false)
			
			Dialogic.start("rizalteodora1")
			
			if not Dialogic.timeline_ended.is_connected(_on_dialogue_finished):
				Dialogic.timeline_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)

func _on_dialogue_finished() -> void:
	var player = get_tree().current_scene.find_child("youngrizal", true, false)
	if player: player.set_physics_process(true)
	
	# Update steps based on your interaction
	QuestManager.update_quest("Story of the Moth", "Listen to Teodora's story of the Moth.", false)
	
	# If they passed the quiz in Dialogic
	if Dialogic.VAR.mothmultiplechoice.mothmultiplehoicefinished == true:
		QuestManager.update_quest("Story of the Moth", "Answer the Narrator's questions about the lesson.", true)
		print("Story of the Moth Complete!")
		start_smooth_transition()

func _on_dialogic_ended() -> void:
	# This handles general dialogue cleanup if the quiz wasn't finished
	var player = get_tree().current_scene.find_child("youngrizal", true, false)
	if player: player.set_physics_process(true)

func start_smooth_transition() -> void:
	Transitionlayer.transition()
	await Transitionlayer.on_transition_finished
	get_tree().change_scene_to_file("res://levels/prelim/2/maestroschool.tscn")



func _on_chatdetection_body_entered(body: Node2D) -> void:
	if body is Player:
		is_near_npc = true
		print("Player near NPC: Press I to chat")

func _on_chatdetection_body_exited(body: Node2D) -> void:
	if body is Player:
		is_near_npc = false
		print("Player left the area")
