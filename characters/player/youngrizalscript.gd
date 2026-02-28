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

	elif scene_path.ends_with("maestroschool.tscn"):
		start_opening_dialogue("2narrator1")

	elif scene_path.ends_with("justianoclassroom.tscn"):
		start_opening_dialogue("2maestrocruzrizal1")

	elif scene_path.ends_with("ateneodemanila.tscn"):
		start_opening_dialogue("3narrator1")

	elif scene_path.ends_with("aclassroom.tscn"):
		start_opening_dialogue("3narrator2")

	elif scene_path.ends_with("ust.tscn"):
		start_opening_dialogue("4narrator1")

	elif scene_path.ends_with("ulecturehalls.tscn"):
		start_opening_dialogue("4narrato2")


# =========================
# OPENING DIALOGUE
# =========================

func start_opening_dialogue(timeline_name: String) -> void:
	if Dialogic.current_timeline != null:
		return

	current_opening_dialogue = timeline_name
	Dialogic.start(timeline_name)


# =========================
# WHEN DIALOGUE ENDS
# =========================

func _on_dialogue_finished() -> void:

	# If Story of the Moth finished → smooth transition
	if current_opening_dialogue == "storyofmoth":
		await start_smooth_transition("res://transitionstoryboard/binan.tscn")
		

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
