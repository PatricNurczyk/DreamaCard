extends CharacterBody2D

var x_force 
var y_force
var flip = false
@onready var polygon = $Polygon
var alpha : float = 1.0
var shooting = false
var modifier = false
var speed : float = 5.0

func _ready():
	x_force = randf_range(200, 300)
	y_force = randf_range(-100,100)
	if flip: x_force = x_force * -1
	await get_tree().create_timer(randf_range(0,.5)).timeout
	if not modifier:
		$AnimationPlayer.play("shake")
	
		
func _physics_process(delta):
	if shooting: alpha = move_toward(alpha, 0, speed * delta)
	modulate = Color(modulate, alpha)
	if alpha == 0:
		queue_free()
	move_and_slide()
	
func flare():
	#$AnimationPlayer.play("flare")
	$AnimationPlayer.stop()
	velocity += Vector2(0,-abs(y_force))
	shooting = true

func shoot():
	$AnimationPlayer.stop()
	velocity += Vector2(x_force,y_force)
	shooting = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "flare":
		$AnimationPlayer.play("shake")
