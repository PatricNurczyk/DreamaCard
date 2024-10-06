extends Node

func select_card(card):
	card.get_parent().get_parent().select_target(card.get_index())
	
func discard():
	print("Cant Discard")

func execute_action(container):
	container.combatants[container.currTurn].MP -= 1
	container.combatants[container.target].takeDamage(7, "frost")
	await container.get_tree().create_timer(1).timeout
	container.action_completed.emit()
