extends AttackAnimation
@onready var sprite = $Swivel/AnimatedSprite2D
@onready var sprite2 = $Swivel/AnimatedSprite2D2
@onready var build = $build
@onready var shoot = $shoot
@onready var shine = $shine
var rotate = 0

func _ready():
	build.play(.5)
	$Swivel.rotation = rotate
	#Engine.time_scale = .5
	
func  _process(delta):
	if sprite.frame == 9:
		build.stop()
		shine.play(.2)
	

func _unhandled_input(event):
	if target_node.is_in_group("Ally"):
		if Input.is_action_just_pressed("Char_" + target_name + "_Guard") and not has_blocked:
			var sprite_pos = sprite.position
			var distance = sprite_pos.distance_to(Vector2(0,-10))
			print(name + " " + str(distance))
			if distance > 50:
				return
			print("Block Pressed "  + name)
			$Timer.start()
			if distance <= 30:
				damage_reduction = 0
			elif distance <= 40:
				damage_reduction = .33
			elif distance <= 50:
				damage_reduction = .66
			#print(str(damage_reduction) + " " + name)

			


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
		if damage_reduction < 1:
			target_node.sprite.stop()
			target_node.sprite.play("guard")
		target_node.takeDamage(damage, "frost")
		hit_effect()

func _on_animated_sprite_2d_animation_finished():
	$AnimationPlayer.play("play_attack")
	await get_tree().create_timer(.05).timeout
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
			hit_effect()
			target_node.takeDamage(damage, "frost")
	else:
		_deal_damage()
	
func create_after_image():
	var afterimage = sprite.duplicate()
	afterimage.modulate = Color("ffffff48")
	afterimage.position = sprite.position
	$Swivel.add_child(afterimage)
	afterimage.play("default")
	await get_tree().create_timer(.1).timeout
	afterimage.queue_free()
	
func hit_effect():
	sprite2.visible = true
	sprite2.play("default")

func _on_animation_player_animation_finished(anim_name):
	finished.emit()
	queue_free()
