extends AttackAnimation
@onready var sprite = $AnimatedSprite2D
@onready var build = $build
@onready var shoot = $shoot
@onready var shine = $shine


func _ready():
	build.play(.5)
	
func  _process(delta):
	if sprite.frame == 9:
		build.stop()
		shine.play(.2)
	

func _unhandled_input(event):
	if target_node.is_in_group("Ally"):
		if Input.is_action_just_pressed("Char_" + target_name + "_Guard") and can_block and not has_blocked:
			var sprite_pos = sprite.position
			var distance = sprite_pos.distance_to(Vector2(0,-10))
			if distance > 40:
				return
			print("Block Pressed "  + name)
			can_block = false
			$Timer.start()
			if distance <= 20:
				damage_reduction = 0
			elif distance <= 30:
				damage_reduction = .33
			elif distance <= 40:
				damage_reduction = .66
			print(str(damage_reduction) + " " + name)

			_deal_damage()

			


func _on_timer_timeout():
	can_block = true
	

func _deal_damage():
	if has_blocked:
		return
	has_blocked = true
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
		print(name)
		target_node.takeDamage(damage, "frost")

func _on_animated_sprite_2d_animation_finished():
	$AnimationPlayer.play("play_attack")
	shoot.play()


func _on_hit():
	if target_node.is_in_group("Enemy"):
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
	else:
		_deal_damage()
	
func create_after_image():
	var afterimage = sprite.duplicate()
	afterimage.modulate = Color("ffffff48")
	afterimage.position = sprite.position
	add_child(afterimage)
	afterimage.play("default")
	await get_tree().create_timer(.1).timeout
	afterimage.queue_free()

func _on_animation_player_animation_finished(anim_name):
	finished.emit()
	queue_free()
