extends Button

func _on_pressed():
	# 'get_parent()' tells the code to look at the node 
	# one level above the button, which is "Controler".
	get_parent().visible = false
	
	# Optional: Print to console to confirm it ran
	print("Menu hidden!")
