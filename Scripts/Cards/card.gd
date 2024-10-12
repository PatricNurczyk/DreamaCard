extends Button
var cardscale: float = .1
var speed: float = 10
var mp_cost: int = 0
@export var card_script : GDScript
@export var initiative : int = 0
@export var target_type : int
@export var SkillName : String
@export var mpCost : int
@export var element : String
var card_instance
var no_hover = false
var greyed = false

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
	#animation_player.play("Card Shake")
	
func cancel():
	no_hover = false
	cardscale = .1
	disabled = false
	z_index = 0
	
func grey_out():
	$Card.modulate = Color("3b3b3b")
	greyed = true
	
func color_in():
	$Card.modulate = Color("ffffff")
	greyed = false
	
func execute_action(container):
	card_instance.execute_action(container)
	
func _on_gui_input(event):
	if not no_hover:
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if not greyed:
						card_instance.select_card(self)
				MOUSE_BUTTON_RIGHT:
					card_instance.discard()
