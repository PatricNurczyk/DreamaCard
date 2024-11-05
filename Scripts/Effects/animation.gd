extends Node2D
class_name AttackAnimation
@onready var animation_player = $AnimationPlayer
var can_block = true
var target_node = null
var damage = 0
var damage_reduction = 1
var bad_roll = false
var target_name = "One"
signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("play_attack")
