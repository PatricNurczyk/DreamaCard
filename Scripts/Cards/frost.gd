extends Node

func select_card(card):
	card.get_parent().get_parent().select_target(card.get_index())
	

func execute_action(container,acc):
	var acc_check = randi_range(1,100) <= acc
	var ANIM = load("res://Scenes/CombatAnimations/Frost.tscn")
	var animation = ANIM.instantiate()
	animation.target_node = container.combatants[container.target]
	if acc_check:
		var damage = await container.combatants[container.currTurn].check_effect_offense(7, "frost")
		container.camera.position = container.combatants[container.target].position
		container.camera_zoom = 6
		await container.get_tree().create_timer(.5).timeout
		container.combatants[container.currTurn].MP -= 1
		#container.combatants[container.target].takeDamage(damage, "frost")
		animation.damage = damage
		container.combatants[container.target].add_child(animation)
		await animation.finished
	else:
		container.camera.position = container.combatants[container.target].position
		container.camera_zoom = 6
		await container.get_tree().create_timer(.5).timeout
		animation.bad_roll = true
		container.combatants[container.target].add_child(animation)
		animation.damage = 7
		await animation.finished
	await container.get_tree().create_timer(.5).timeout
	container.acc_result = acc_check
	container.action_completed.emit()
