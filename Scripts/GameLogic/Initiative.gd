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
var buff_ui = null

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
		if get_parent().get_parent().get_parent().combatState != 1 and get_parent().get_parent().get_parent().combatState != 2:
			return
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if buff_ui == null:
					for b in get_parent().get_parent().get_node("Ally Initiative").get_children():
						if is_instance_valid(b.buff_ui):
							b.buff_ui.despawn()
							b.buff_ui = null
					for b in get_parent().get_parent().get_node("Enemy Initiative").get_children():
						if is_instance_valid(b.buff_ui):
							b.buff_ui.despawn()
							b.buff_ui = null
					buff_ui = BUFF_UI.instantiate()
					for b in character.get_node("buffs").get_children():
						buff_ui.effects.append(b)
					for d in character.get_node("dots").get_children():
						buff_ui.effects.append(d)
					buff_ui.hp = str(character.HP)
					buff_ui.mp = str(character.MP)
					buff_ui.nameplate = character.name
					buff_ui.portrait = character.portrait
					buff_ui.global_position.y = global_position.y
					if character.is_in_group("Ally"):
						#buff.global_position += Vector2(200,-60)
						var x_offset = get_parent().get_global_rect().end.x
						buff_ui.global_position += Vector2(x_offset,-150)
					else:
						#buff.global_position += Vector2(200,-60)
						var x_offset = get_parent().get_global_rect().position.x - buff_ui.get_size().x
						buff_ui.global_position += Vector2(x_offset,-150)
						buff_ui.flip = true
					get_parent().get_parent().add_child(buff_ui)
				else:
					buff_ui.despawn()
					buff_ui = null
