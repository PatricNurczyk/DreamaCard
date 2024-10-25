extends Control
@onready var animation_player = $AnimationPlayer
var is_despawning = false
var effects = []
@onready var text = $text

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("spawn")
	for e in effects:
		
		#dot
		if e.has_method("flare"):
			text.text += str(e.value) + " " + e.element.capitalize() + " Damage over " + str(e.turns) + " turn" + ("s" if e.turns > 1 else "") + "\n\n"
		#modifier
		else:
			match(e.type):
				"offense":
					text.text += ("+" if e.value >= 0 else "") + str(e.value * 100) + "% to " + ("next " if e.turns == 0 else "") + e.element.capitalize() + " attack\n\n"


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
