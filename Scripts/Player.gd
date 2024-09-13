extends CharacterBody2D

const WALK = 60.0
const SPRINT = 90.0

@onready var sprite = $AnimatedSprite2D
var SPEED = 30.0
var direction = "right"
var can_walk = true

func _physics_process(delta):
	
	
	if can_walk:
		if Input.is_action_pressed("Sprint"):
			SPEED = SPRINT
			sprite.speed_scale = 1.5
		else:
			SPEED = WALK
			sprite.speed_scale = 1
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction_X = Input.get_axis("ui_left", "ui_right")
		if direction_X:
			velocity.x = direction_X * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		var direction_Y = Input.get_axis("ui_up", "ui_down")
		if direction_Y:
			velocity.y = direction_Y * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
			
	handle_animation(velocity)

	move_and_slide()


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
