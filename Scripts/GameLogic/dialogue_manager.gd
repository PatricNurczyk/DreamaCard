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
var loaded_battle_theme = null
signal finished

var state_tracker = {
	"map_first_load" : true,
	1: 0,
	2: true,
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
		#{ "position" : null, "line" : "Hello, and welcome"},
		#{ "position" : null, "line" : "It appears you have fallen into the greatest trap of all"},
		#{ "position" : null, "line" : "being my test subject"},
		#{ "position" : null, "line" : "Well I guess it really isn't exactly a trap, you're supposed to be having fun"},
		#{ "position" : null, "line" : "Anyway this means you need to fight me, and not die immediately"},
		#{ "position" : null, "line" : "How might one do this, well I will give you a basic jist"},
		#{ "position" : null, "line" : "This is a card game, Each player on the field has 6 cards from their deck, and a weapon card"},
		#{ "position" : null, "line" : "You can [Left Click] to select a card, and [Right Click] to discard it, but you can't [Right Click] your weapon card"},
		#{ "position" : null, "line" : "If all the crypid ass symbols make absolutely no sense, you can hover over a card, and press [TAB] to get more info on what it does"},
		#{ "position" : null, "line" : "I will try to pelt you to death with Frost spells, which fortunately you can guard"},
		#{ "position" : null, "line" : "Pressing [1] will guard against attacks targeted towards you, since you are the 1st party member"},
		#{ "position" : null, "line" : "Timing is super important, so hitting [1] at the right time can completely negate all damage"},
		#{ "position" : null, "line" : "Ok, thats about it, better get ready, I'm really fast, I gave you a basic deck to start with"},
		{ "position" : null, "line" : "HAAVVEEE FUNNN", "autocontinue" : true},
		{ "position" : null, "line" : init_combat, "parameters": ["res://Sounds/Music/DECISIVE BATTLE.mp3"]},
		{ "position" : null, "line" : "Nice You won, thanks for playing!!!"},
	],
	3 : [
		{ "position" : null, "line" : "........"},
		{ "position" : null, "line" : "Bro...you already won, I can't help you"},
	],
	4 : [
		{ "position" : Vector2(100,153), "line" : "Hey, how did you get here?"},
	],
	5 : [
		{ "position" : null, "line" : "Wait a minute, you're not like the rest of us."},
		{ "position" : null, "line" : "NahNahNahNahNahNahNahNahNahNahNahNahNahNahNahNahNahNahNahNah"},
		{ "position" : null, "line" : "No you're different"},
		{ "position" : null, "line" : "come over here and talk to me by pressing [SPACE]"}
	],
	6 : [
		{ "position" : null, "line" : "chop chop, and don't come back till the prince has been defeated"}
	]
}


func _unhandled_input(event):
	if Input.is_action_just_pressed("advance_dialogue") and is_dialog and can_advance:
		text_box.queue_free()
		advance()


func play_dialog(c : CharacterBody2D, lines_id : int):
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
		finished.emit()
		return
	show_text()
	
func init_combat(parameters = null):
	if parameters:
		loaded_battle_theme = game_container.battle_music.stream
		game_container.battle_music.stream = load(parameters[0])
		game_container.pause_position = 0
	if game_container:
		game_container.combat_completed.connect(_on_combat_finished)
		game_container.start_combat()
	
func _on_combat_finished():
	if loaded_battle_theme:
		game_container.battle_music.stream = loaded_battle_theme
		game_container.pause_position = 0
		loaded_battle_theme = null
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
