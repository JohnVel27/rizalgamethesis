extends TileMap

var AstarGrid: AStarGrid2D

func _ready() -> void:
	LevelManager.change_tilemap_bounds( _get_tilemap_bounds())
	assigning_astar()

func assigning_astar() -> void:
	var used_rect = get_used_rect()
	AstarGrid = AStarGrid2D.new()
	AstarGrid.region = used_rect
	AstarGrid.cell_size = tile_set.tile_size
	AstarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AstarGrid.update()
	
	for x in range(used_rect.size.x):
		for y in range(used_rect.size.y):
			var tile_position = Vector2i(x + used_rect.position.x, y + used_rect.position.y)
			
			# FIX: Changed index 1 to 0 because layers are 0-indexed
			var tile_data = get_cell_tile_data(0, tile_position)
			
			if tile_data != null:
				# Ensure your TileSet has a Custom Data Layer named "Walkable"
				if tile_data.get_custom_data("Walkable") == false:
					AstarGrid.set_point_solid(tile_position)
					
func _get_tilemap_bounds() -> Array[ Vector2 ]:
	var bounds : Array[ Vector2 ] = []
	bounds.append(
		Vector2( get_used_rect().position * rendering_quadrant_size ) 
	)
	bounds.append(
		Vector2( get_used_rect().end * rendering_quadrant_size ) 
	)
	return bounds
