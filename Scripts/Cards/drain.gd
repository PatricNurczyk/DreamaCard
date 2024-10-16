extends Node

func select_card(card):
	card.get_parent().get_parent().select_target(card.get_index())
	
func discard():
	print("Cant Discard")

func execute_action(container):
	var roll = randi_range(1,100)
	print(roll)
	var acc_check = roll <= await container.combatants[container.currTurn].check_accuracy(80, "void")
	if acc_check:
		var damage = await container.combatants[container.currTurn].check_effect_offense(5, "void")
		container.camera.position = container.combatants[container.target].position
		container.camera_zoom = 6
		await container.get_tree().create_timer(.5).timeout
		container.combatants[container.currTurn].MP -= 1
		damage = container.combatants[container.target].takeDamage(damage, "void")
		await container.get_tree().create_timer(.3).timeout
		container.camera.position = container.battleground.position
		container.camera_zoom = 4.5
		await container.get_tree().create_timer(.3).timeout
		container.combatants[container.currTurn].heal(damage * 1.5)
	else:
		container.camera.position = container.combatants[container.target].position
		container.camera_zoom = 6
		await container.get_tree().create_timer(.5).timeout
		var d_num = load("res://Scenes/GameLogic/damage_number.tscn")
		d_num = d_num.instantiate()
		d_num.number = -1
		d_num.position += Vector2(0,-5)
		d_num.color = "ffffff"
		d_num.altColor = "000000"
		container.combatants[container.target].add_child(d_num)
	await container.get_tree().create_timer(.5).timeout
	container.acc_result = acc_check
	container.action_completed.emit()
