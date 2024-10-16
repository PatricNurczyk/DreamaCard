extends Node

func select_card(card):
	card.get_parent().get_parent().select_target(card.get_index())
	
func discard():
	print("Cant Discard")

func execute_action(container):
	container.camera.position = container.battleground.position
	container.camera_zoom = 4.5
	var roll = randi_range(1,100)
	print(roll)
	var acc_check = roll <= await container.combatants[container.currTurn].check_accuracy(100, "light")
	if acc_check:
		container.combatants[container.currTurn].MP -= 1
		var heal = await container.combatants[container.currTurn].check_effect_heal(10)
		container.combatants[container.target].heal(heal)
	else:
		var d_num = load("res://Scenes/GameLogic/damage_number.tscn")
		d_num = d_num.instantiate()
		d_num.number = -1
		d_num.position += Vector2(0,-5)
		d_num.color = "ffffff"
		d_num.altColor = "000000"
		container.combatants[container.target].add_child(d_num)
		#var heal = await container.combatants[container.currTurn].check_effect_heal(10)
		container.combatants[randi_range(0,len(container.combatants) - 1)].heal(10)
	await container.get_tree().create_timer(.75).timeout
	container.acc_result = acc_check
	container.action_completed.emit()
