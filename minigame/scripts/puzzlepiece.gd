extends Area2D
#puzzle_piece

var index = -1
var cell_index = -1

var dragging = false
var drag_offset = Vector2.ZERO

@onready var sprite2d: Sprite2D = $Sprite2D
@onready var collishape: CollisionShape2D = $CollisionShape2D

func init_piece(
	_index: int,
	texture: ImageTexture,
	pos: Vector2,
	piece_size: Vector2
):
	index = _index
	sprite2d.texture = texture
	position = pos
	collishape.shape.set("size", piece_size)
	
	


@warning_ignore("unused_parameter")
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if G.dragging and dragging == false:
		
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			#Drag it
			
			#reset cell
			if cell_index != -1:
				var cell = G.find_cell(cell_index)
				cell.unoccupy()
				cell_index = -1
			
			G.dragging = true
			dragging = true
			z_index = 100
			drag_offset = global_position - get_global_mouse_position()
		else:
			#Button Release
			G.dragging = false
			dragging = false
			z_index = 0
			drop_piece()
			G.check_win()
	elif event is InputEventMouseMotion and dragging:
		var new_pos = get_global_mouse_position() + drag_offset
		position = new_pos
			

func drop_piece():
	#Check whether to place piece in a cell
	var overlapping_areas = get_overlapping_areas()
	for cell in overlapping_areas:
		if cell.is_in_group("cell"):
			if cell.is_free():
				cell_index = cell.index 
				cell.occupy()
				position = cell.global_position
				return
