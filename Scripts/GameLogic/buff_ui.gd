extends Control
@onready var animation_player = $AnimationPlayer
var is_despawning = false
var effects = []
@onready var buffs = $TextureRect/buffs
@onready var hp_text = $TextureRect/HP
@onready var mp_text = $TextureRect/MP
@onready var nameplate_text = $TextureRect/Name
@onready var portrait_img = $Portrait
var hp : String
var mp : String
var nameplate : String
var portrait : Texture2D
var flip : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("spawn")
	nameplate_text.text = "[center][b][font_size=30]" + nameplate + "[/font_size][/b][/center]"
	hp_text.text = hp
	mp_text.text = mp
	portrait_img.texture = portrait
	if flip:
		portrait_img.flip_h = true
	for e in effects:
		
		#dot
		if e.has_method("flare"):
			buffs.text += str(e.value) + " " + e.element.capitalize() + " Damage over " + str(e.turns) + " turn" + ("s" if e.turns > 1 else "") + "\n"
		#modifier
		else:
			match(e.type):
				"offense":
					buffs.text += ("+" if e.value >= 0 else "") + str(e.value * 100) + "% " + ("next " if e.turns < 0 else "") + (("Attack" if e.turns < 0 else "to all Attacks") if e.element == "universal" else e.element.capitalize() + " Attack") + (" for " + str(e.turns) + (" turns" if e.turns != 1 else " turn") if e.turns > 0 else "") + "\n"
				"accuracy attack":
					buffs.text += ("+" if e.value >= 0 else "") + str(e.value) + "% Accuracy " + ("next " if e.turns < 0 else "") + (("Attack" if e.turns < 0 else "to all Attacks") if e.element == "universal" else e.element.capitalize() + " Attack") + (" for " + str(e.turns) + (" turns" if e.turns != 1 else " turn") if e.turns > 0 else "") + "\n"
				"accuracy":
					buffs.text += ("+" if e.value >= 0 else "") + str(e.value) + "% Accuracy " + ("next " if e.turns < 0 else "") + (("Card" if e.turns < 0 else "") if e.element == "universal" else e.element.capitalize() + " Card") + (" for " + str(e.turns) + (" turns" if e.turns != 1 else " turn") if e.turns > 0 else "") + "\n"
				"defense":
					buffs.text += "Block " + ("+" if e.value >= 0 else "") + str(e.value * 100) + "% " + ("next " if e.turns < 0 else "") + (("Attack" if e.turns < 0 else "of all Attack") if e.element == "universal" else e.element.capitalize() + " Attack") + ("s for " + str(e.turns) + (" turns" if e.turns != 1 else " turn") if e.turns > 0 else "") + "\n"
				"stun":
					buffs.text += "Stunned for " + str(e.turns) + (" turns\n" if e.turns != 1 else " turn\n") 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
 
func despawn():
	if not is_despawning:
		is_despawning = true
		animation_player.play("despawn")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "despawn":
		queue_free()


func _on_texture_rect_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				despawn()
