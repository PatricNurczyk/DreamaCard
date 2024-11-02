extends Node

@onready var text_box_scene = preload("res://Scenes/GameLogic/text_box.tscn")

var char_lines : int = -1
var curr_line_index = 0

var text_box : Node
var text_box_pos : Vector2
var is_dialog : bool = false
var can_advance : bool = false
var game_container
enum gameStates {explore, combat, cutscene, transition}
var currState = gameStates.explore

var state_tracker = {
	1: 0,
	2: false,
	3: false
}

#SIGNAL LIST
signal slimes_beaten




var dialogue = {
	1 : [
		{ "position" : null, "line" : "Hello, I see you have fallen into my little test room"},
		{ "position" : null, "line" : "We...don't get a whole lot of visitors...and uhhh...."},
		{ "position" : null, "line" : "We are itttching for another game, and noticed you got some fine cards on you"},
		{ "position" : null, "line" : "............"},
		{ "position" : null, "line" : "What do you mean you don't know how you got them"},
		{ "position" : null, "line" : "............"},
		{ "position" : null, "line" : "You don't even know how to play either......."},
		{ "position" : null, "line" : "...it really isn't that hard"},
		{ "position" : null, "line" : "Just run into any one of my fine gooooey friends here, and the board will appear"},
		{ "position" : null, "line" : "You're main resource is Mana, or MP for short. You get one per turn, and can store up to 2 right now"},
		{ "position" : null, "line" : "Each turn, the player with the highest initiative (The White Bar) goes next"},
		{ "position" : null, "line" : "You can hold up to 6 cards at a time, with the 7th being your weapon card, which will never leave you"},
		{ "position" : null, "line" : "Click on a card an a target to use a card"},
		{ "position" : null, "line" : "............"},
		{ "position" : null, "line" : "No you shouldn't need help figuring out what cards do, and pressing [TAB] on a card will do NOTHING"},
		{ "position" : null, "line" : "................probably"},
		{ "position" : null, "line" : "Each card will have a Mana cost and Accuracy"},
		{ "position" : null, "line" : "If you can't use the card use 0 Mana cost cards to build your resource"},
		{ "position" : null, "line" : "Alright, now you know, so uh now ram your head into as many slimes as possible"},
	],
	2 : [
		{ "position" : null, "line" : "Oh...well that was fast...guess its my turn."},
		{ "position" : null, "line" : "Alright, well good luck, I got a lot of HP cause the developer is too lazy to properly balance"},
		{ "position" : null, "line" : init_combat, "parameters": null},
		{ "position" : null, "line" : "Nice You won, thanks for playing!!!"},
	],
	3 : [
		{ "position" : null, "line" : "........"},
		{ "position" : null, "line" : "Bro...you already won, I can't help you"},
	]
}


func _unhandled_input(event):
	if Input.is_action_just_pressed("advance_dialogue") and is_dialog and can_advance:
		text_box.queue_free()
		advance()


func play_dialog(c : CharacterBody2D, lines_id: int):
	if is_dialog:
		return
	is_dialog = true
	currState = gameStates.cutscene
	char_lines = lines_id
	text_box_pos = c.global_position
	show_text()
	
func show_text():
	if typeof(dialogue[char_lines][curr_line_index]["line"]) == TYPE_CALLABLE:
		if not dialogue[char_lines][curr_line_index]["parameters"]:
			dialogue[char_lines][curr_line_index]["line"].call()
		else:
			dialogue[char_lines][curr_line_index]["line"].call(dialogue[char_lines][curr_line_index]["parameters"])
		can_advance = false
		return
	text_box =  text_box_scene.instantiate()
	text_box.finished.connect(_on_text_box_finished)
	if dialogue[char_lines][curr_line_index]["position"] == null:
		text_box.global_position = text_box_pos
		print(text_box.global_position)
	else:
		text_box.global_position = dialogue[char_lines][curr_line_index]["position"]
	get_tree().root.add_child(text_box)
	text_box.display_text(dialogue[char_lines][curr_line_index]["line"])
	can_advance = false
	
	
func _on_text_box_finished():
	can_advance = true
	
	
func advance():
	curr_line_index += 1
	if curr_line_index >= len(dialogue[char_lines]):
		is_dialog = false
		char_lines = -1
		curr_line_index = 0
		currState = gameStates.explore
		return
	show_text()
	
func init_combat():
	if game_container:
		game_container.combat_completed.connect(_on_combat_finished)
		game_container.start_combat()
	
func _on_combat_finished():
	if char_lines > 0:
		if curr_line_index >= len(dialogue[char_lines]):
			game_container.combat_completed.disconnect(_on_combat_finished)
			currState = gameStates.explore
		else:
			currState = gameStates.cutscene
			advance()
	else:
		game_container.combat_completed.disconnect(_on_combat_finished)
		currState = gameStates.explore
