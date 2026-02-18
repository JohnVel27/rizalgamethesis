extends CharacterBody2D

# Track if player is inside detection area
var is_near_npc: bool = false

func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_dialogic_ended)

func _input(event: InputEvent) -> void:
	# Check if interact key is pressed
	if event.is_action_pressed("interact") and is_near_npc:
		if Dialogic.current_timeline == null:
			var player = get_tree().current_scene.find_child("youngrizal", true, false)
			if player:
				player.set_physics_process(false)
			Dialogic.start("4dominicanfriarsrizal1")

func _on_dialogic_ended() -> void:
	var player = get_tree().current_scene.find_child("youngrizal", true, false)
	if player:
		player.set_physics_process(true)
		
	# Check dialog choice result
	if Dialogic.VAR.dominicanfriarsrizal.dominicanfriarsrizalfinished == true:
		start_smooth_transition()
		
func start_smooth_transition() -> void:
	Transitionlayer.transition()
	await Transitionlayer.on_transition_finished
	get_tree().change_scene_to_file("res://GUI/mainmenu/levels.tscn")

	

func _on_chatdetectiondfriar_body_entered(body: Node2D) -> void:
	# Only set to true if the thing entering the area is the Player
	if body is Player: 
		is_near_npc = true
		print("Player near NPC: Press I to chat")


func _on_chatdetectiondfriar_body_exited(body: Node2D) -> void:
	if body is Player:
		is_near_npc = false
		print("Player left the area")
