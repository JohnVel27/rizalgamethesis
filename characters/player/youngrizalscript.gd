extends CharacterBody2D
class_name Player

@export var inventory_data: InventoryData

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var tile_map: TileMap
var astar: AStarGrid2D

var current_id_path: Array[Vector2i] = []
var speed: float = 160.0
var last_direction: Vector2 = Vector2.DOWN

var current_opening_dialogue := ""

func _ready() -> void:
	
	self.process_mode = PROCESS_MODE_ALWAYS
	
	if get_tree().current_scene.has_node("TileMap"):
		tile_map = get_tree().current_scene.get_node("TileMap")
	else:
		push_error("TileMap not found in current scene!")

	# Connect once only
	if not Dialogic.timeline_ended.is_connected(_on_dialogue_finished):
		Dialogic.timeline_ended.connect(_on_dialogue_finished)

	var scene_path = get_tree().current_scene.scene_file_path

	if scene_path.ends_with("rizalhome.tscn"):
		start_opening_dialogue("Narrator-calamba")

	elif scene_path.ends_with("livingroomrizal.tscn"):
		start_opening_dialogue("narrator-livingroom")

	elif scene_path.ends_with("storyofthemoth.tscn"):
		start_opening_dialogue("storyofmoth")
		
	elif scene_path.ends_with("leavingtocalamba.tscn"):
		start_opening_dialogue("goingtobinan")

	elif scene_path.ends_with("maestroschool.tscn"):
		start_opening_dialogue("2narrator1")

	elif scene_path.ends_with("justianoclassroom.tscn"):
		start_opening_dialogue("2maestrocruzrizal1")
		
	elif scene_path.ends_with("juanchocarrera.tscn"):
		start_opening_dialogue("2juanchorizal1")
		
	elif scene_path.ends_with("maestroschool1.tscn"):
		start_opening_dialogue("brawlmission")

	elif scene_path.ends_with("ateneodemanila.tscn"):
		start_opening_dialogue("3narrator1")

	elif scene_path.ends_with("ust.tscn"):
		start_opening_dialogue("4narrator1")

	elif scene_path.ends_with("res://levels/prelim/4/uhallway.tscn"):
		start_opening_dialogue("4narrato2")

	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.signal_event.connect(_on_dialogic_juancho_signal)
# =========================
# OPENING DIALOGUE
# =========================

func start_opening_dialogue(timeline_name: String) -> void:
	# Prevent starting if a dialogue is already running
	if Dialogic.current_timeline != null:
		return
	
	current_opening_dialogue = timeline_name
	
	# Start the specific timeline
	Dialogic.start(timeline_name)
	
# =========================
# WHEN DIALOGUE ENDS
# =========================

func _on_dialogic_signal(argument: String) -> void:
	if argument != "puzzlegame":
		return

	# --- Find the puzzle UI in the current scene ---
	var puzzle_ui = get_tree().current_scene.find_child("Gamelamp", true, false)
	if not puzzle_ui:
		push_error("Puzzle UI 'Gamemoth' not found in scene!")
		return

	# --- Freeze the player ---
	var player = get_tree().current_scene.find_child("youngrizal", true, false)
	if player:
		player.set_physics_process(false)

	
	velocity = Vector2.ZERO

	# --- Show the puzzle ---
	puzzle_ui.visible = true

	# --- Show the start overlay if exists ---
	var overlay = puzzle_ui.find_child("Startoverlay", true, false)
	if overlay:
		overlay.visible = true

	# --- Start the board / scramble ---
	var board_node = puzzle_ui.find_child("Boardlamp", true, false)
	if board_node:
		board_node._on_Tile_pressed(-1)

		# --- FIX: Wait for the puzzle to be completed ---
		# In Godot 4, we use 'await' followed by the signal name directly.
		await board_node.game_won 

		# Optional: Only proceed if a certain story is finished
		if current_opening_dialogue == "storyofmoth":
			await start_smooth_transition("res://levels/prelim/1/leavingtocalamba.tscn")

	# --- Unfreeze the player ---
	if player:
		player.set_physics_process(true)
		

func _on_dialogic_juancho_signal(argument: String) -> void:
	if argument != "minigamepuzzleart":
		return

	# 1. I-SAVE ANG TREE AGAD sa simula pa lang ng function
	var tree = get_tree()
	if not tree: return # Safety check
	
	var scene = tree.current_scene

	# --- Find the puzzle UI in the current scene ---
	# Gamitin ang 'scene' variable imbes na get_tree().current_scene
	var puzzle_ui = scene.find_child("Gameart", true, false)
	if not puzzle_ui:
		push_error("Puzzle UI 'Gameart' not found in scene!")
		return

	# --- Freeze the player ---
	var player = scene.find_child("youngrizal", true, false)
	if player:
		player.set_physics_process(false)

	velocity = Vector2.ZERO

	# --- Show the puzzle ---
	puzzle_ui.visible = true

	# --- Show the start overlay if exists ---
	var overlay = puzzle_ui.find_child("Startoverlay", true, false)
	if overlay:
		overlay.visible = true

	# --- Start the board / scramble ---
	var board_node = puzzle_ui.find_child("Boardart", true, false)
	if board_node:
		board_node._on_Tile_pressed(-1)

		# --- FIX: Wait for the puzzle to be completed ---
		await board_node.game_won 

		# Siguraduhin na 'tree' reference pa rin ang gamit natin dito
		if current_opening_dialogue == "2juanchorizal1":
			# Siguraduhin na ang start_smooth_transition function mo ay tumatanggap ng 'tree' reference
			await start_smooth_transition("res://levels/prelim/3/ateneodemanila.tscn")

	# --- Unfreeze the player ---
	# Re-check player existence after await
	if is_instance_valid(player):
		player.set_physics_process(true)
	

func _on_dialogue_finished() -> void:
		
	if current_opening_dialogue == "goingtobinan":
		await start_smooth_transition("res://transitionstoryboard/binan.tscn")
	
	if current_opening_dialogue == "2maestrocruzrizal1":
		await start_smooth_transition("res://levels/prelim/2/maestroschool1.tscn")
		
	current_opening_dialogue = ""


# =========================
# SMOOTH TRANSITION
# =========================

func start_smooth_transition(next_scene: String) -> void:
	
	# If you have a global Transitionlayer (Autoload)
	if has_node("/root/Transitionlayer"):
		Transitionlayer.transition()
		await Transitionlayer.on_transition_finished
	
	get_tree().change_scene_to_file(next_scene)


# =========================
# INPUT
# =========================

func _input(event: InputEvent) -> void:
	if Dialogic.current_timeline != null:
		return

	if event.is_action_pressed("RightClick"):
		set_path_to_mouse()


func set_path_to_mouse() -> void:
	if astar == null:
		astar = tile_map.AstarGrid
	if astar == null:
		return

	var start_point: Vector2i = tile_map.local_to_map(global_position)
	var end_point: Vector2i = tile_map.local_to_map(get_global_mouse_position())
	
	current_id_path = astar.get_id_path(start_point, end_point)
	if current_id_path.size() > 0:
		current_id_path.remove_at(0)


func _physics_process(_delta: float) -> void:
	if Dialogic.current_timeline != null:
		play_idle_animation()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if current_id_path.is_empty():
		play_idle_animation()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var target_position: Vector2 = tile_map.map_to_local(current_id_path[0])

	if global_position.distance_to(target_position) < 2:
		current_id_path.pop_front()
		return

	move_to_target(target_position)


func move_to_target(target: Vector2) -> void:
	var direction: Vector2 = (target - global_position).normalized()
	last_direction = direction
	velocity = direction * speed
	move_and_slide()
	play_walk_animation(direction)


func play_walk_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.play("carry_walk_side_right")
		else:
			sprite.play("carry_walk_side_left")
	else:
		if dir.y > 0:
			sprite.play("carry_walk_down")
		else:
			sprite.play("carry_walk_up")


func play_idle_animation() -> void:
	if abs(last_direction.x) > abs(last_direction.y):
		if last_direction.x > 0:
			sprite.play("carry_idle_side_right")
		else:
			sprite.play("carry_idle_side_left")
	else:
		if last_direction.y > 0:
			sprite.play("carry_idle_down")
		else:
			sprite.play("carry_idle_up")
