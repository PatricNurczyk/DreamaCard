extends AttackAnimation


func _unhandled_input(event):
	if target_node.is_in_group("Ally"):
		if Input.is_action_just_pressed("Char_" + target_name + "_Guard") and can_block and not has_blocked:
			print("Block Pressed")
			can_block = false
			$Timer.start()
			var frame = $AnimatedSprite2D.frame

			match frame:
				12,16:
					damage_reduction = .66
					has_blocked = true
					_deal_damage()
				13,15:
					damage_reduction = .33
					has_blocked = true
					_deal_damage()
				14:
					damage_reduction = 0
					has_blocked = true
					_deal_damage()
			


	
func _process(delta):
	if target_node.is_in_group("Enemy") and $AnimatedSprite2D.frame == 14 and not has_blocked:
		has_blocked = true
		if bad_roll:
			target_node.dodge_animation()
			var d_num = load("res://Scenes/GameLogic/damage_number.tscn")
			d_num = d_num.instantiate()
			d_num.number = -1
			d_num.position += Vector2(0,-5)
			d_num.color = "ffffff"
			d_num.altColor = "000000"
			target_node.add_child(d_num)
		else:
			target_node.takeDamage(damage, "frost")


func _on_timer_timeout():
	can_block = true
	

func _deal_damage():
	if bad_roll and damage_reduction < 1:
		target_node.dodge_animation()
		var d_num = load("res://Scenes/GameLogic/damage_number.tscn")
		d_num = d_num.instantiate()
		d_num.number = -1
		d_num.position += Vector2(0,-5)
		d_num.color = "ffffff"
		d_num.altColor = "000000"
		target_node.add_child(d_num)
	else:
		damage *= damage_reduction
		if damage_reduction < 1:
			target_node.sprite.play("guard")
		target_node.takeDamage(damage, "frost")

func _on_animated_sprite_2d_animation_finished():
	if not has_blocked:
		_deal_damage()
	finished.emit()
	queue_free()
