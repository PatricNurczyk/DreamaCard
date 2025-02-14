extends CharacterBody2D
class_name EntityCharacter

@export var WALK = 60.0
@export var SPRINT = 90.0
@export var keepAfterDeath = false
@onready var animation_player = $AnimationPlayer
@onready var collision = $CollisionShape2D
var is_running = false

@onready var sprite = $AnimatedSprite2D
var SPEED = 30.0
var direction = "right"
var can_walk = true
var is_dead = false
var in_combat = false
var is_idle = true
var is_stun = false
@onready var name_ui = $name

#effects UI
var effects : Array 
@onready var buffs = $buffs
@onready var dots = $dots
var effect_check = false
var effect_offset = 10

#Character Stats
@export_category("Basic Stats")
@export var maxHP : int
var HP : int
@export var maxMP : int
var MP : int
@export var speed : int
@export var duoChance : float

@export_category("Outgoing Boost")
@export var fireBoost : int
@export var frostBoost : int
@export var lightningBoost : int
@export var earthBoost : int
@export var voidBoost : int
@export var lightBoost : int
@export var damageBoost : int

@export_category("Incoming Resistance")
@export var fireResist : int
@export var frostResist : int
@export var lightningResist : int
@export var earthResist : int
@export var voidResist : int
@export var lightResist : int
@export var defense : int

@export_category("Portrait")
@export var portrait : Texture2D

var deck : Array[String]
var hand : Array[String]
func _ready():
	HP = maxHP
	sprite.animation_finished.connect(_on_animation_finished)
	name_ui.text = "[center][font_size=10]" + name + "[/font_size][/center]"
	
func _process(delta):
	if not effect_check:
		for buff in buffs.get_children():
			if buff.get_index() < 12:
				buff.new_pos.x = effect_offset * (buff.get_index()%4)
				buff.new_pos.y = 15 * floor(buff.get_index()/4)
			else:
				buff.new_pos.x = effect_offset * 3
				buff.new_pos.y = 15 * 2
	#for debuff in debuffs.get_children():
		#debuff.position.x = effect_offset * debuff.get_index()

func handle_animation():
	if in_combat:
		collision.set_deferred("disabled", true)
		if direction == "right":
			sprite.flip_h = false
		elif direction == "left":
			sprite.flip_h = true
		return
	else:
		collision.set_deferred("disabled", false)
	if velocity.x > 0:
		direction = "right"
	elif velocity.x < 0:
		direction = "left"
	else:
		if velocity.y > 0:
			direction = "down"
		elif velocity.y < 0:
			direction = "up"
	match direction:
		"up":
			if velocity == Vector2(0,0):
				sprite.play("idle_up")
			else:
				sprite.play("move_up")
		"down":
			if velocity == Vector2(0,0):
				sprite.play("idle_down")
			else:
				sprite.play("move_down")
		"left":
			sprite.flip_h = true
			if velocity == Vector2(0,0):
				sprite.play("idle_side")
				
			else:
				if is_running : sprite.play("run_side") 
				else: sprite.play("move_side")
		"right":
			sprite.flip_h = false
			if velocity == Vector2(0,0):
				sprite.play("idle_side")
			else:
				if is_running : sprite.play("run_side") 
				else: sprite.play("move_side")


func takeDamage(value: int, element: String):
	var damage : int
	var d_num = load("res://Scenes/GameLogic/damage_number.tscn")
	d_num = d_num.instantiate()
	match(element):
		"physical":
			damage = value * (100 - defense)/100
			d_num.color = "ffffff"
			d_num.altColor = "000000"
		"fire":
			damage = value * (100 - defense - fireResist)/100
			d_num.color = "d5621f"
			d_num.altColor = "ff0000"
		"frost":
			damage = value * (100 - defense - frostResist)/100
			d_num.color = "00ffff"
			d_num.altColor = "0000ff"
		"lightning":
			damage = value * (100 - defense - lightningResist)/100
			d_num.color = "c3d511"
			d_num.altColor = "ef9926"
		"earth":
			damage = value * (100 - defense - earthResist)/100
			d_num.color = "6e5003"
			d_num.altColor = "005000"
		"void":
			damage = value * (100 - defense - voidResist)/100
			d_num.color = "#8e43f7"
			d_num.altColor = "#572f8f"
		"light":
			damage = value * (100 - defense - lightResist)/100
			d_num.color = "#f5ff69"
			d_num.altColor = "#aab058"
		"arcane":
			damage = value * (100 - defense)/100
			d_num.color = "#4fffbe"
			d_num.altColor = "#61c780"
	d_num.number = damage
	d_num.position += Vector2(0,-5)
	add_child(d_num)
	HP = max(HP - damage, 0)
	if damage > 0:
		sprite.play("hurt")
		$hurt.play()
	else:
		$guard.play()
	is_idle = false
	if HP == 0:
		is_dead = true
		on_death_battle()
		sprite.play("death") 
		for e in buffs.get_children():
			e.fire()
		for d in dots.get_children():
			d.fire()
	return damage
			
func heal(value: int):
	var h_num = load("res://Scenes/GameLogic/heal_number.tscn")
	h_num = h_num.instantiate()
	h_num.number = value
	h_num.position += Vector2(0,-5)
	add_child(h_num)
	HP = min(HP + value, maxHP)
	
func add_effect(type : String, value, element : String, turns : int, custom_icon : String = ""):
	if is_dead:
		return
	var mod
	match type:
		"modifier attack":
			mod = preload("res://Scenes/GameLogic/modifier.tscn").instantiate()
			mod.element = element
			mod.value = value
			mod.turns = turns
			mod.type = "offense"
			var texture	
			#effects.push_back(mod)
			if value > 0:
				#mod.position.x += effect_offset * len($buffs.get_children())
				texture = load("res://Assets/Icons/attack_Good.png")
			else:
				#mod.position.x += effect_offset * len($debuffs.get_children())
				texture = load("res://Assets/Icons/attack_Bad.png")
			mod.icon_img = texture
		"accuracy":
			mod = preload("res://Scenes/GameLogic/modifier.tscn").instantiate()
			mod.element = element
			mod.value = value
			mod.turns = turns
			mod.type = "accuracy"
			var texture	
			#effects.push_back(mod)
			if value > 0:
				#mod.position.x += effect_offset * len($buffs.get_children())
				texture = load("res://Assets/Icons/accuracy_Good.png")
			else:
				#mod.position.x += effect_offset * len($debuffs.get_children())
				texture = load("res://Assets/Icons/accuracy_Bad.png")
			mod.icon_img = texture
		"accuracy attack":
			mod = preload("res://Scenes/GameLogic/modifier.tscn").instantiate()
			mod.element = element
			mod.value = value
			mod.turns = turns
			mod.type = "accuracy attack"
			var texture	
			#effects.push_back(mod)
			if value > 0:
				#mod.position.x += effect_offset * len($buffs.get_children())
				texture = load("res://Assets/Icons/accuracy_Good.png")
			else:
				#mod.position.x += effect_offset * len($debuffs.get_children())
				texture = load("res://Assets/Icons/accuracy_Bad.png")
			mod.icon_img = texture
		"stun":
			mod = preload("res://Scenes/GameLogic/modifier.tscn").instantiate()
			mod.element = element
			mod.value = value
			mod.turns = turns
			mod.type = "stun"
			var texture = load("res://Assets/Icons/Stun.png")
			mod.icon_img = texture
	var length = len(buffs.get_children())
	if length < 12:
		mod.position.x = effect_offset * (length%4)
		mod.position.y = 15 * floor(length/4)
	else:
		mod.position.x = effect_offset * 3 
		mod.position.y = 15 * 2
	$buffs.add_child(mod)

func add_dot(damage : int, element: String, turns : int):
	if is_dead:
		return
	var mod = preload("res://Scenes/GameLogic/dot.tscn").instantiate()
	mod.element = element
	mod.value = damage
	mod.turns = turns
	$dots.add_child(mod)
	
func check_turn():
	effect_check = true
	for d in dots.get_children():
		d.trigger_effect()
		await get_tree().create_timer(.2).timeout
		if is_dead:
			return
	for e in buffs.get_children():
		if e.turns > 0:
			if e.type == "stun":
				is_stun = true
				var damage : int
				var d_num = load("res://Scenes/GameLogic/damage_number.tscn")
				d_num = d_num.instantiate()
				d_num.number = -2
				d_num.color = "ffffff"
				d_num.altColor = "000000"
				d_num.position += Vector2(0,-5)
				add_child(d_num)
			e.turns -= 1
			if e.type == "stun" and e.turns == 0:
				e.fire()
				await get_tree().create_timer(.2).timeout
		elif e.turns == 0:
			e.fire()
			await get_tree().create_timer(.2).timeout
	effect_check = false
	await get_tree().create_timer(.1).timeout
			
func check_accuracy(accuracy : int, element: String, attack: bool = false):
	while effect_check:
		pass
	effect_check = true
	for e in buffs.get_children():
		if e.type == "accuracy attack" and attack and (e.element == element or e.element == "universal"):
			accuracy += e.trigger_effect()
			await get_tree().create_timer(.2).timeout
		elif e.type == "accuracy" and (e.element == element or e.element == "universal"):
			accuracy += e.trigger_effect()
			await get_tree().create_timer(.2).timeout
	effect_check = false
	return accuracy
			
func check_effect_offense(damage: int, element: String):
	while effect_check:
		pass
	effect_check = true
	var totalMod = 1
	for e in buffs.get_children():
		if e.type == "offense" and (e.element == element or e.element == "universal"):
			totalMod += e.trigger_effect()
			await get_tree().create_timer(.2).timeout
	effect_check = false
	return damage * totalMod

func check_effect_heal(heal: int):
	effect_check = true
	var totalMod = 1
	for e in buffs.get_children():
		if e.type == "heal":
			totalMod += e.trigger_effect()
			await get_tree().create_timer(.2).timeout
	effect_check = false
	return heal * totalMod
	
func clean_effects():
	for e in buffs.get_children():
		e.fire()
	for d in dots.get_children():
		d.fire()
	
func _on_animation_finished():
	#if sprite.animation == "attack_break":
	#	sprite.play("battle_idle")
	if sprite.animation == "hurt":
		sprite.play("battle_idle")
	if sprite.animation == "guard":
		sprite.play("battle_idle")
	if sprite.animation == "prep_battle":
		sprite.play("battle_idle")
	if sprite.animation == "attack_break":
		sprite.play("battle_idle")


func check_nearby_player(size : int):
	var space := get_world_2d().direct_space_state
	var search = PhysicsShapeQueryParameters2D.new()
	search.transform = global_transform
	var shape = CircleShape2D.new()
	shape.radius = size
	search.shape = shape
	var bodies = space.intersect_shape(search)
	for b in bodies:
		if b.collider.is_in_group("Player"):
			return true
	return false


func on_death_battle():
	pass
	
func on_death_post_battle():
	pass


func dodge_animation():
	animation_player.stop()
	if (randi()%2 == 0):
		animation_player.play("dodge")
	else:
		animation_player.play("dodge_2")

func create_after_image():
	var afterimage = sprite.duplicate()
	afterimage.modulate = Color("ffffff59")
	afterimage.position = sprite.position
	add_child(afterimage)
	await get_tree().create_timer(.2).timeout
	afterimage.queue_free()
