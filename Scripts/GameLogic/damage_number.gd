extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng = RandomNumberGenerator.new()
var number : int = 0
@onready var label = $Label

func _ready():
	label.text = str(number)
	velocity.y = JUMP_VELOCITY
	velocity.x = rng.randf_range(-50.0, 50.0)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()


func _on_timer_timeout():
	queue_free()
