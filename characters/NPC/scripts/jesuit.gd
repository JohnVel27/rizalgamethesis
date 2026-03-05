extends CharacterBody2D

@export var move_speed: float = 60.0

var tile_map: TileMap
var astar: AStarGrid2D
var player: Player
var current_path: Array[Vector2i] = []

var path_update_timer: float = 0.0
var path_update_delay: float = 0.3

var dialogue_active: bool = false
var dialogue_finished_once: bool = false

func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_dialogic_ended)

	# Get TileMap (sibling)
	tile_map = get_parent().get_node("TileMap")
	astar = tile_map.AstarGrid

	# Get Player
	player = get_parent().get_node("youngrizal")


func _physics_process(delta: float) -> void:
	if not player or not astar:
		return

	if dialogue_active:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	path_update_timer += delta
	if path_update_timer >= path_update_delay:
		update_path()
		path_update_timer = 0.0

	move_along_path()


func update_path():
	var npc_cell = tile_map.local_to_map(global_position)
	var player_cell = tile_map.local_to_map(player.global_position)

	if astar.is_in_boundsv(npc_cell) and astar.is_in_boundsv(player_cell):
		current_path = astar.get_id_path(npc_cell, player_cell)


func move_along_path():
	if current_path.size() <= 1:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var next_cell = current_path[1]
	var next_position = tile_map.map_to_local(next_cell)
	var direction = (next_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

	if global_position.distance_to(next_position) < 4:
		current_path.remove_at(0)


# 🔥 Area2D auto triggers dialogue
func _on_chatdetectionjesuit_body_entered(body: Node2D) -> void:
	if body is Player and not dialogue_finished_once:
		start_dialogue()


func start_dialogue() -> void:
	dialogue_active = true
	dialogue_finished_once = true

	# Freeze both
	player.set_physics_process(false)
	set_physics_process(false)

	Dialogic.start("3sanchezrizal1")


# 🔥 Called when any Dialogic timeline ends
func _on_dialogic_ended() -> void:
	dialogue_active = false
	if player:
		player.set_physics_process(true)
		set_physics_process(true)

	if Dialogic.VAR.sanchezrizalmultiplechoice.sanchezrizalmultiplechoicefinished == true:
		start_smooth_transition()


func start_smooth_transition() -> void:
	Transitionlayer.transition()
	await Transitionlayer.on_transition_finished
	get_tree().change_scene_to_file("res://transitionstoryboard/usttranslationstory/ust1.tscn")
