extends Node2D

@onready var cells = $cells
@onready var cell_scene = preload("res://minigame/scenes/cell.tscn")

@onready var  pieces = $pieces
@onready var pieces_scene = preload("res://minigame/scenes/puzzlepiece.tscn")

#var piece_size: Vector2 = Vector2.ZERO
var piece_size: Vector2 = Vector2(100, 100)

func _ready():
	init_game()
	
func init_game():
	generate_pieces()
	draw_cells()

func draw_cells():
	for i in range(G.grid_size.x):
		for j in range(G.grid_size.y):
			add_cell(i, j)
			
func add_cell(i, j):
	var cell = cell_scene.instantiate()
	cells.add_child(cell)
	G.cells.append(cell)
	cell.position = Vector2(
		int(piece_size.x) * i,
		int(piece_size.y) * j
	)
	var idx = int(i * G.grid_size.x) + j
	cell.init_cell(idx, piece_size)
	
func generate_pieces():
	var image: Image = G.get_image()
	var texture = ImageTexture.create_from_image(image)
	piece_size = Vector2(
		texture.get_width() / G.grid_size.x,
		texture.get_height() / G.grid_size.y
	)
	
	for i in range(G.grid_size.x):
		for j in range(G.grid_size.y):
			var piece = pieces_scene.instantiate()
			pieces.add_child(piece)
			G.pieces.append(piece)
			
			#Select Region from image
			var region = Rect2(i * piece_size.x, j * piece_size.y, piece_size.x,  piece_size.y)
			var sub_image = image.get_region(Rect2(region.position, region.size))
			var sub_tex = ImageTexture.create_from_image(sub_image)
			var pos
			var index = int(i * G.grid_size.x + j)
			
			if index < G.grid_size.x * G.grid_size.y:
				pos = Vector2(
					randi_range(100, 200),
					randi_range(200, 800),
				)
			else:
				pos = Vector2(
					randi_range(600, 800),
					randi_range(200, 800),
				)
			
			piece.init_piece(
				index,
				sub_tex,
				pos,
				piece_size
			)
