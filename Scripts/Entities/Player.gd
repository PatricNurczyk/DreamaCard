extends EntityCharacter


func _physics_process(delta):	
	if DialogueManager.currState == DialogueManager.gameStates.explore:
		if Input.is_action_pressed("Sprint"):
			SPEED = SPRINT
			sprite.speed_scale = 1.5
		else:
			SPEED = WALK
			sprite.speed_scale = 1
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction_X = Input.get_axis("ui_left", "ui_right")
		if direction_X:
			velocity.x = direction_X * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		var direction_Y = Input.get_axis("ui_up", "ui_down")
		if direction_Y:
			velocity.y = direction_Y * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
	else:
		velocity = Vector2.ZERO
	handle_animation()

	move_and_slide()


func _on_area_2d_area_entered(area):
	if area.is_in_group("Enemy"):
		velocity = Vector2.ZERO
		sprite.speed_scale = 1
		DialogueManager.init_combat()


func _on_animated_sprite_2d_animation_finished():
	pass # Replace with function body.
