extends MapTemplate
@onready var transition1 = $TransitionEvent
@onready var animation_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	if DialogueManager.state_tracker[1] == 4:
		$TileMap2.visible = false
		transition1.visible = true
		$Slime.queue_free()
		$Slime3.queue_free()
		$Slime4.queue_free()
		$Slime6.queue_free()
	DialogueManager.slimes_beaten.connect(_on_slimes_beaten)
	if not DialogueManager.state_tracker["map_first_load"]:
		DialogueManager.state_tracker["map_first_load"] = true
		await get_parent().map_loaded
		await get_tree().create_timer(.5).timeout
		DialogueManager.play_dialog($"King Slime", 4)
		await DialogueManager.finished
		DialogueManager.currState = DialogueManager.gameStates.cutscene
		get_parent().camera.position = Vector2(51,62)
		await get_tree().create_timer(1).timeout
		DialogueManager.play_dialog($"King Slime", 5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_slimes_beaten():
	DialogueManager.currState = DialogueManager.gameStates.cutscene
	get_parent().camera.position = Vector2(456,143)
	await get_tree().create_timer(1).timeout
	animation_player.play("lower_spikes")


func _on_animation_player_animation_finished(anim_name):
	DialogueManager.currState = DialogueManager.gameStates.explore
