extends CharacterBody2D
class_name Player

@export var inventory_data: InventoryData

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var tile_map: TileMap
var astar: AStarGrid2D

var current_id_path: Array[Vector2i] = []
var speed: float = 100.0
var last_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	tile_map = get_parent().get_node("TileMap")
	
	
	var scene_path = get_tree().current_scene.scene_file_path
	
	if scene_path == "res://levels/prelim/1/rizalhome.tscn":
		start_opening_dialogue("Narrator-calamba")
		
	elif scene_path == "res://levels/prelim/1/livingroomrizal.tscn":
		start_opening_dialogue("narrator-livingroom")
		
	elif scene_path == "res://levels/prelim/2/maestroschool.tscn":
		start_opening_dialogue("2narrator1")
		
	elif scene_path == "res://levels/prelim/2/justianoclassroom.tscn":
		start_opening_dialogue("2narrator2")
		
	#This is the old rizal script:
	elif scene_path == "res://levels/prelim/3/ateneodemanila.tscn":
		start_opening_dialogue("3narrator1")
		
	elif scene_path == "res://levels/prelim/3/aclassroom.tscn":
		start_opening_dialogue("3narrator2")
		
	elif scene_path == "res://levels/prelim/4/ust.tscn":
		start_opening_dialogue("4narrator1")
		
	elif scene_path == "res://levels/prelim/4/ulecturehalls.tscn":
		start_opening_dialogue("4narrato2")
		
	

func start_opening_dialogue(timeline_name: String) -> void:
	# Safety check to prevent overlapping timelines
	if Dialogic.current_timeline != null:
		return
	
	Dialogic.start(timeline_name)

func _input(event: InputEvent) -> void:
	# Disable input while dialogue is active
	if Dialogic.current_timeline != null:
		return

	if event.is_action_pressed("RightClick"):
		set_path_to_mouse()

func set_path_to_mouse() -> void:
	# Refresh Astar reference if it wasn't ready during _ready()
	if astar == null:
		astar = tile_map.AstarGrid
	
	if astar == null: return

	var start_point: Vector2i = tile_map.local_to_map(global_position)
	var end_point: Vector2i = tile_map.local_to_map(get_global_mouse_position())
	
	current_id_path = astar.get_id_path(start_point, end_point)
	
	if current_id_path.size() > 0:
		current_id_path.remove_at(0)

func _physics_process(_delta: float) -> void:
	# Force the player to stop and idle if a dialogue is currently playing
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

	# Snap to target if very close
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
		# Horizontal movement
		sprite.flip_h = false # Reset flip
		if dir.x > 0:
			sprite.play("carry_walk_side_right")
		else:
			sprite.play("carry_walk_side_left")
	else:
		# Vertical movement
		if dir.y > 0:
			sprite.play("carry_walk_down")
		else:
			sprite.play("carry_walk_up")

func play_idle_animation() -> void:
	if abs(last_direction.x) > abs(last_direction.y):
		# Horizontal idle
		if last_direction.x > 0:
			sprite.play("carry_idle_side_right")
		else:
			sprite.play("carry_idle_side_left")
	else:
		# Vertical idle
		if last_direction.y > 0:
			sprite.play("carry_idle_down")
		else:
			sprite.play("carry_idle_up")
