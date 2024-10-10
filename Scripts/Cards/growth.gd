extends Node

func select_card(card):
	card.get_parent().get_parent().select_target(card.get_index())
	
func discard():
	print("Cant Discard")

func execute_action(container):
	#container.camera.position = container.combatants[container.target].position
	#container.camera_zoom = 6
	container.combatants[container.target].add_effect("modifier attack", .5, "earth", 0)
	await container.get_tree().create_timer(.75).timeout
	container.action_completed.emit()
