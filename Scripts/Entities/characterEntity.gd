extends CharacterBody2D
class_name EntityCharacter

@export var WALK = 60.0
@export var SPRINT = 90.0

@onready var sprite = $AnimatedSprite2D
var SPEED = 30.0
var direction = "right"
var can_walk = true


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


func _ready():
	HP = maxHP

func handle_animation():
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
	match(element):
		"physical":
			damage = value * (100 - defense)/100
		"fire":
			damage = value * (100 - defense - fireResist)/100
		"frost":
			damage = value * (100 - defense - frostResist)/100
		"lightning":
			damage = value * (100 - defense - lightningResist)/100
		"earth":
			damage = value * (100 - defense - earthResist)/100
		"void":
			damage = value * (100 - defense - voidResist)/100
		"light":
			damage = value * (100 - defense - lightResist)/100
		"arcane":
			damage = value * (100 - defense)/100
	var d_num = load("res://Scenes/GameLogic/damage_number.tscn")
	d_num = d_num.instantiate()
	d_num.number = damage
	add_child(d_num)
	HP = max(HP - damage, 0)
	
