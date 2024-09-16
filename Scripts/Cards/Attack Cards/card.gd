extends Button

var cardscale: float = .1
var speed: float = 10
var mp_cost: int = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Card.scale.x = lerp($Card.scale.x, cardscale, speed * delta)
	$Card.scale.y = lerp($Card.scale.y,cardscale, speed * delta)
	
func _on_mouse_entered():
	get_parent().move_child(self,-1)
	$hover.play()
	cardscale = .25
	z_index = 2

func _on_mouse_exited():
	cardscale = .1
	z_index = 0
	
	
func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				print("Use")
			MOUSE_BUTTON_RIGHT:
				print("Can't Discard")
