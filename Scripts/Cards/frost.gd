extends Node
var ANIM = load("res://Scenes/CombatAnimations/Frost.tscn")

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
		#var d_num = load("res://Scenes/GameLogic/damage_number.tscn")
		#d_num = d_num.instantiate()
		#d_num.number = -1
		#d_num.position += Vector2(0,-5)
		#d_num.color = "ffffff"
		#d_num.altColor = "000000"
		animation.bad_roll = true
		container.combatants[container.target].add_child(animation)
		animation.damage = 7
		await animation.finished
	await container.get_tree().create_timer(.5).timeout
	container.acc_result = acc_check
	container.action_completed.emit()
