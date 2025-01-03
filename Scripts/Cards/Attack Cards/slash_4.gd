extends Node

func discard():
	print("Cant Discard")


func execute_action(container,acc):
	var acc_check = randi_range(1,100) <= acc
	if acc_check:
		var damage = await container.combatants[container.currTurn].check_effect_offense(4, "physical")
		container.combatants[container.target].takeDamage(damage, "physical")
	else:
		await container.get_tree().create_timer(.5).timeout
		var d_num = load("res://Scenes/GameLogic/damage_number.tscn")
		d_num = d_num.instantiate()
		d_num.number = -1
		d_num.position += Vector2(0,-5)
		d_num.color = "ffffff"
		d_num.altColor = "000000"
		container.combatants[container.target].add_child(d_num)
	await container.get_tree().create_timer(.5).timeout
	container.acc_result = acc_check
	container.action_completed.emit()


func get_velocity_vector(initial_position: Vector2, final_position: Vector2, time_interval: float) -> Vector2:
	# Calculate displacement vector
	var displacement = final_position - initial_position

	# Calculate velocity vector
	var velocity = displacement / time_interval

	return velocity
