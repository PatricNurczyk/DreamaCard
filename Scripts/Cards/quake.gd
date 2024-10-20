extends Node

func select_card(card):
	card.get_parent().get_parent().select_target(card.get_index())
	
func discard():
	print("Cant Discard")

func execute_action(container,acc):
	var target_enemy = container.combatants[container.target].is_in_group("Enemy")
	var firstHit = false
	var damage
	container.camera.position = container.battleground.position
	container.camera_zoom = 5
	for c in container.combatants:
		if target_enemy and c.is_in_group("Enemy") and not c.is_dead:
			var acc_check = randi_range(1,100) <= acc
			if acc_check:
				if not firstHit:
					damage = await container.combatants[container.currTurn].check_effect_offense(10, "earth")
					container.combatants[container.currTurn].MP -= 2
					firstHit = true
				await container.get_tree().create_timer(.2).timeout
				c.takeDamage(damage, "earth")
			else:
				await container.get_tree().create_timer(.2).timeout
				var d_num = load("res://Scenes/GameLogic/damage_number.tscn")
				d_num = d_num.instantiate()
				d_num.number = -1
				d_num.position += Vector2(0,-5)
				d_num.color = "ffffff"
				d_num.altColor = "000000"
				c.add_child(d_num)
	await container.get_tree().create_timer(.5).timeout
	container.acc_result = firstHit
	container.action_completed.emit()
