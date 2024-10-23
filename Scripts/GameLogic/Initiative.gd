extends HBoxContainer
@onready var text = $name
@onready var hp = $Bars/HP
@onready var hpLabel = $Bars/HP/Label
@onready var mp = $Bars/MP
@onready var mpLabel = $Bars/MP/Label
@onready var init_bar = $Bars/init_bar
@export var barName : String
@export var initiative : int
@export var maxHP : int
@export var HP : int
@export var maxMP : int
@export var MP : int
const SPEED = 300
const BUFF_UI = preload("res://Scenes/GameLogic/buff_ui.tscn")
var character : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	text.text = barName


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hp.max_value = maxHP
	hp.value = move_toward(hp.value, HP, 2 * maxHP * delta)
	hpLabel.text = str(int(hp.value)) + "/" + str(maxHP)
	
	mp.max_value = maxMP
	mp.value = move_toward(mp.value, MP, 10 * delta)
	mpLabel.text = str(int(mp.value)) + "/" + str(maxMP)
	
	init_bar.value = move_toward(init_bar.value, initiative, SPEED * delta)
	
func changeYellow():
	init_bar.modulate = Color("ffff42")
	
func changeWhite():
	init_bar.modulate = Color("ffffff")


func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				print(global_position)
				var buff = BUFF_UI.instantiate()
				buff.global_position = global_position
				print(buff.global_position)
				get_parent().get_parent().add_child(buff)
				
			MOUSE_BUTTON_RIGHT:
				print(barName + " Closed")
