extends TextureButton

var normal_atlas = preload("res://GUI/instruction/normalbutton.tres")
var hover_atlas = preload("res://GUI/instruction/hovertexture.tres")
var controller_scene = preload("res://GUI/instruction/controler.tscn")

func _ready():
	texture_normal = normal_atlas
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_button_pressed)

func _on_mouse_entered():
	texture_normal = hover_atlas
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_mouse_exited():
	texture_normal = normal_atlas
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _on_button_pressed():
	print("Button clicked!")
	
	var controller = controller_scene.instantiate()
	get_tree().current_scene.add_child(controller)
