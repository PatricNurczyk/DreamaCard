extends CharacterBody2D

var number : int = 0
@onready var label = $Label
var y : float = -300

func _ready():
	if number == -1:
		label.text = "Miss"
	else:
		label.text = str(number)
	$Timer.start()
	$AudioStreamPlayer2D.play()

func _physics_process(delta):
	velocity.y = y
	move_and_slide()
	y = move_toward(y,0,delta * 900)


func _on_timer_timeout():
	queue_free()
