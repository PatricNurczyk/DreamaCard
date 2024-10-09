extends Node

func select_card(card):
	card.get_parent().get_parent().select_target(card.get_index())
	
func discard():
	print("Cant Discard")

func execute_action(container):
	var damage = await container.combatants[container.currTurn].check_effect_offense(7, "light")
	container.camera.position = container.combatants[container.target].position
	container.camera_zoom = 6
	await container.get_tree().create_timer(.5).timeout
	container.combatants[container.currTurn].MP -= 1
	container.combatants[container.target].takeDamage(damage, "light")
	await container.get_tree().create_timer(.5).timeout
	container.action_completed.emit()
