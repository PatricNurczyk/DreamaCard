extends Node

func select_card(card):
	card.get_parent().get_parent().select_target(card.get_index())
	
func discard():
	print("Cant Discard")

func execute_action(container):
	container.camera.position = container.battleground.position
	container.camera_zoom = 4.5
	container.combatants[container.target].add_effect("modifier attack", .4, "fire", 0)
	await container.get_tree().create_timer(.75).timeout
	container.action_completed.emit()
