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
@export var arcaneBoost : int

@export_category("Incoming Resistance")
@export var fireResist : int
@export var frostResist : int
@export var lightningResist : int
@export var earthResist : int
@export var voidResist : int
@export var lightResist : int
@export var arcaneResist : int


func handle_animation(velocity : Vector2):
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