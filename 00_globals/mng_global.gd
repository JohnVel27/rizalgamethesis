extends Node

var cells = []
var pieces = []

var dragging = false

const images = [
	"res://asset/mng_puzzle/el fili.jpg",
	"res://asset/mng_puzzle/noli.png"
]

enum DIFFICULTY {
	EASY,
	MEDIUM,
	HARD
}

const DIFFICULTY_VALUES = {
	DIFFICULTY.EASY: 3,
	DIFFICULTY.MEDIUM: 8,
	DIFFICULTY.HARD: 10
}

var chosen_difficulty = DIFFICULTY.EASY
var grid_size = Vector2i(
	DIFFICULTY_VALUES[chosen_difficulty],
	DIFFICULTY_VALUES[chosen_difficulty]
)

func get_image():
	var image = Image.load_from_file(images.pick_random())
	return image 
	
func find_cell(index: int):
	for cell in cells:
		if cell.index == index:
			return cell
	
func check_win():
	for piece in pieces:
		if piece.index != piece.cell_index:
			return
		print("NIGGER")
