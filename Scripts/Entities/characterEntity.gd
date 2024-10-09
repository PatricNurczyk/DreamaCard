extends CharacterBody2D
class_name EntityCharacter

@export var WALK = 60.0
@export var SPRINT = 90.0

@onready var sprite = $AnimatedSprite2D
var SPEED = 30.0
var direction = "right"
var can_walk = true
var is_dead = false
var in_combat = false
var is_idle = true

#effects UI
var effects : Array 
@onready var buffs = $buffs
@onready var debuffs = $debuffs
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

var deck : Array[String]
var hand : Array[String]
func _ready():
	HP = maxHP
	sprite.animation_finished.connect(_on_animation_finished)
	
func _process(delta):
	for buff in buffs.get_children():
		buff.position.x = effect_offset * buff.get_index()
	for debuff in debuffs.get_children():
		debuff.position.x = effect_offset * debuff.get_index()

func handle_animation():
	if in_combat:
		if is_idle and not is_dead:
			sprite.play("idle_side")
		return
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
				sprite.play("move_side")
		"right":
			sprite.flip_h = false
			if velocity == Vector2(0,0):
				sprite.play("idle_side")
			else:
				sprite.play("move_side")


func takeDamage(value: int, element: String):
	$hurt.play()
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
	sprite.play("hurt")
	is_idle = false
	if HP == 0:
		is_dead = true
		sprite.play("death") 
	
func add_effect(type : String, value, element : String, turns : int):
	match type:
		"modifier attack":
			var mod = preload("res://Scenes/GameLogic/modifier.tscn").instantiate()
			mod.element = element
			mod.value = value
			mod.turns = turns
			var texture	
			#effects.push_back(mod)
			if value > 0:
				#mod.position.x += effect_offset * len($buffs.get_children())
				texture = load("res://Assets/Icons/" + ("attack" if element == "universal" else element)  + "_Good.png")
				mod.icon_img = texture
				$buffs.add_child(mod)
			else:
				#mod.position.x += effect_offset * len($debuffs.get_children())
				texture = load("res://Assets/Icons/" + ("attack" if element == "universal" else element)  + "_Bad.png")
				mod.icon_img = texture
				$debuffs.add_child(mod)
			
func check_effect_offense(damage: int, element: String):
	for e in buffs.get_children():
		if e.element == element or e.element == "universal":
			damage = e.trigger_effect(damage)
			await get_tree().create_timer(.3).timeout
	for e in debuffs.get_children():
		if e.element == element or e.element == "universal":
			damage = e.trigger_effect(damage)
			await get_tree().create_timer(.3).timeout
	return damage
	
func clean_effects():
	for e in buffs.get_children():
		e.fire()
	for e in debuffs.get_children():
		e.fire()
	
func _on_animation_finished():
	if sprite.animation == "attack_break":
		is_idle = true
	if sprite.animation == "hurt":
		is_idle = true
