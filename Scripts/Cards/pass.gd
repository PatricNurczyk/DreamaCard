extends Button

var cardscale: float = .1
var speed: float = 10
var mp_cost: int = 0
@export var initiative : int = 0
var no_hover = false
var centered : bool


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Card.scale.x = lerp($Card.scale.x, cardscale, speed * delta)
	$Card.scale.y = lerp($Card.scale.y,cardscale, speed * delta)
	
func _on_mouse_entered():
	if not no_hover:
		$hover.play()
		cardscale = .18
		z_index = 2

func _on_mouse_exited():
	if not no_hover:
		cardscale = .1
		z_index = 0

func cancel():
	no_hover = false
	cardscale = .1
	disabled = false
	
func execute_action():
	get_parent().get_parent().pass_turn()
	
func _on_gui_input(event):
	if not no_hover:
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					execute_action()
