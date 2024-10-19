extends Node

func execute_action(container,acc):
	container.camera.position = container.battleground.position
	container.camera_zoom = 4.5
	var acc_check = randi_range(1,100) <= acc
	if acc_check:
		container.combatants[container.target].add_effect("modifier attack", .35, "void", 0)
	else:
		var d_num = load("res://Scenes/GameLogic/damage_number.tscn")
		d_num = d_num.instantiate()
		d_num.number = -1
		d_num.position += Vector2(0,-5)
		d_num.color = "ffffff"
		d_num.altColor = "000000"
		container.combatants[container.target].add_child(d_num)
		container.combatants[randi_range(0,len(container.combatants) - 1)].add_effect("modifier attack", .35, "void", 0)
	await container.get_tree().create_timer(.75).timeout
	container.acc_result = acc_check
	container.action_completed.emit()
