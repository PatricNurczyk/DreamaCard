extends Node

func select_card(card):
	card.get_parent().get_parent().select_target(card.get_index())
	
func discard():
	print("Cant Discard")

func execute_action(container):
	var acc_check = await randi_range(1,100) <= container.combatants[container.currTurn].check_accuracy(80, "fire")
	if acc_check:
		var damage = await container.combatants[container.currTurn].check_effect_offense(4, "fire")
		var dot = 12 * (damage/4)
		container.camera.position = container.combatants[container.target].position
		container.camera_zoom = 6
		await container.get_tree().create_timer(.5).timeout
		container.combatants[container.currTurn].MP -= 1
		container.combatants[container.target].takeDamage(damage, "fire")
		container.combatants[container.target].add_dot(dot, "fire", 2)
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