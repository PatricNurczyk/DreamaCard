extends Control

var element : String = ""
var mp_cost : int = 0
var accuracy : int = 0
var description : String = ""
var can_close = false
var select = false
var lock = false
@onready var label = $RichTextLabel
@onready var open = $open
@onready var close = $close

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = "[center][font_size=10]\nAffinity: " + element.capitalize() + "\nMP Cost: " + str(mp_cost) + "\nAccuracy: " + str(accuracy) + "%\n\n" + description + "[/font_size][/center]"
	get_parent().get_node("Card").modulate = Color("3b3b3b")
	open.play()
	await get_tree().create_timer(.2).timeout
	can_close = true

func _input(event):
	if event is InputEventMouseButton:
		var mouse = get_global_mouse_position()
		if abs(global_position.x - mouse.x) <= 26 or abs(global_position.y - mouse.y) <= 40 and event.pressed:
			if Input.is_action_just_pressed("Click"):
				if not get_parent().greyed and not lock:
					lock = true
					select = true
					print("selectInput" + str(Time.get_time_dict_from_system()))
					get_parent().get_parent().reset()
					get_parent().card_selected()
					get_parent().get_parent().get_parent().select_target(get_parent().get_index())
					get_parent().get_node("Card").modulate = Color("ffffff")
					queue_free()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if get_parent().discardable:
					get_parent().discarded = true
	elif Input.is_action_just_pressed("inspect_toggle"):
		if can_close:
			get_parent()._on_mouse_exited()
			close.play()
			await get_tree().create_timer(.2).timeout
			select = true
			get_parent()._on_mouse_exited()
			get_parent().get_parent().reset()
			if not get_parent().greyed:
				get_parent().get_node("Card").modulate = Color("ffffff")
			queue_free()

func _process(delta):
	if not select:
		get_parent().cardscale = .18
		get_parent().z_index = 2
