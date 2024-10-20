extends Node2D


func focused(index):
	for i in get_children():
		if i.get_index() != index:
			i.no_hover = true
		else:
			i.centered = true
			
func reset():
	for i in get_children():
		if i.has_method("execute_action"):
			i.no_hover = false
			i.centered = false
			#if i.get_global_rect().has_point(get_global_mouse_position()):
				#i._on_mouse_entered()
