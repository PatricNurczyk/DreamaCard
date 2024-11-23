extends Node2D
class_name AttackAnimation
@onready var animation_player = $AnimationPlayer
var can_block = true
var target_node = null
var damage = 0
var damage_reduction = 1
var bad_roll = false
var target_name = "One"
var has_blocked = false
signal finished
