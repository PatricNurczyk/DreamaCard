extends Node

func select_card(card):
	card.get_parent().get_parent().select_target(card.get_index())
	
func discard():
	print("Cant Discard")


func execute_action(container):
	container.combatants[container.target].takeDamage(4, "physical")
	await container.get_tree().create_timer(1).timeout
	container.action_completed.emit()


func get_velocity_vector(initial_position: Vector2, final_position: Vector2, time_interval: float) -> Vector2:
	# Calculate displacement vector
	var displacement = final_position - initial_position

	# Calculate velocity vector
	var velocity = displacement / time_interval

	return velocity
