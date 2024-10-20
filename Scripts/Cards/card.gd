extends Button

const DESC_SCENE = preload("res://Scenes/GameLogic/card_description.tscn")

var cardscale: float = .1
var speed: float = 10
var mp_cost: int = 0
@export var card_script : GDScript
@export var initiative : int = 0
@export var target_type : int
@export var SkillName : String
@export var mpCost : int
@export var element : String
@export var discardable : bool
@export var accuracy : int = 100
@export var is_attack : bool = false
@export_multiline var description: String = ""
var discarded : bool = false
var alpha : float = 1
var card_instance
var no_hover = false
var greyed = false
var centered = false
var mouse_in = false

# Called when the node enters the scene tree for the first time.
func _ready():
	card_instance = card_script.new()

func _input(event):
	if Input.is_action_just_pressed("inspect_toggle") and mouse_in and not no_hover:
			get_parent().focused(get_index())
			var des_scene = DESC_SCENE.instantiate()
			des_scene.element = element
			des_scene.accuracy = accuracy
			des_scene.mp_cost = mpCost
			des_scene.description = description
			add_child(des_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Card.scale.x = lerp($Card.scale.x, cardscale, speed * delta)
	$Card.scale.y = lerp($Card.scale.y,cardscale, speed * delta)
	if discarded:
		alpha = move_toward(alpha, 0, speed * delta)
		modulate = Color(modulate, alpha)
		if alpha == 0:
			get_parent().reset()
			queue_free()
	
func _on_mouse_entered():
	if not no_hover:
		$hover.play()
		cardscale = .18
		z_index = 2
		mouse_in = true

func _on_mouse_exited():
	if not no_hover:
		cardscale = .1
		z_index = 0
		mouse_in = false
	
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
	
func execute_action(container,acc):
	card_instance.execute_action(container,acc)
	
func _on_gui_input(event):
	if not no_hover:
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if not greyed:
						#print("selectCard")
						get_parent().get_parent().select_target(get_index())
				MOUSE_BUTTON_RIGHT:
					if discardable:
						discarded = true
