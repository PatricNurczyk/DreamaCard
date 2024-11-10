extends Node
var ANIM = load("res://Scenes/CombatAnimations/Frost.tscn")

func select_card(card):
	card.get_parent().get_parent().select_target(card.get_index())
	

func execute_action(container,acc):
	var acc_check = randi_range(1,100) <= acc
	var ANIM = load("res://Scenes/CombatAnimations/Ice Shard.tscn")
	var ANIM2 = load("res://Scenes/CombatAnimations/Ice Shard2.tscn")
	var animation = ANIM.instantiate()
	var animation2 = ANIM2.instantiate()
	animation.target_node = container.combatants[container.target]
	animation2.target_node = container.combatants[container.target]
	if acc_check:
		var damage = await container.combatants[container.currTurn].check_effect_offense(12, "frost")
		container.camera.position = container.combatants[container.target].position
		container.camera_zoom = 6
		await container.get_tree().create_timer(.5).timeout
		container.combatants[container.currTurn].MP -= 2
		animation.damage = damage / 2
		animation2.damage = damage / 2
		container.combatants[container.target].add_child(animation)
		await container.get_tree().create_timer(randf_range(.3,.5)).timeout
		container.combatants[container.target].add_child(animation2)
		await animation.finished
		await animation2.finished
	else:
		container.camera.position = container.combatants[container.target].position
		container.camera_zoom = 6
		await container.get_tree().create_timer(.5).timeout
		animation.bad_roll = true
		animation2.bad_roll = true
		animation.damage = 6
		animation2.damage = 6
		container.combatants[container.target].add_child(animation)
		await container.get_tree().create_timer(.5).timeout
		container.combatants[container.target].add_child(animation2)
		await animation.finished
		await animation2.finished
		
	await container.get_tree().create_timer(.3).timeout
	container.acc_result = acc_check
	container.action_completed.emit()
