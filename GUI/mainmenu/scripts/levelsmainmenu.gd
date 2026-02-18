extends Node

func _on_prelim_pressed() -> void:
	Transitionlayer.transition()
	await Transitionlayer.on_transition_finished
	get_tree().change_scene_to_file("res://levels/prelim/1/rizalhome.tscn")
