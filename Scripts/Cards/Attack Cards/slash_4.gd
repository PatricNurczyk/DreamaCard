extends Node

func select_card(card):
	card.card_selected()
	card.get_parent().get_parent().select_target(card.get_index())
	
func discard():
	print("Cant Discard")


func execute_action(container):
	container.combatants[container.target].takeDamage(4, "physical")
	await container.get_tree().create_timer(1).timeout
	container.action_completed.emit()
