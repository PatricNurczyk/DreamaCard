extends Button

var cardscale: float = .1
var speed: float = 10
var mp_cost: int = 0
@export var card_script : GDScript
@export var initiative : int = 0
var card_instance
var no_hover = false
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	card_instance = card_script.new()


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
	
func card_selected():
	cardscale = .05
	no_hover = true
	animation_player.play("Card Shake")
	disabled = true
	
func cancel():
	no_hover = false
	cardscale = .1
	animation_player.stop()
	disabled = false
	
	
func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				card_instance.select_card(self)
			MOUSE_BUTTON_RIGHT:
				card_instance.discard()

