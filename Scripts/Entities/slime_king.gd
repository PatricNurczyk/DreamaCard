extends EntityCharacter

@export var deck_template : Array[String]
var has_talked = false
var prioritize

func _unhandled_input(event):
	if Input.is_action_just_pressed("Interact") and check_nearby_player(12):
		if DialogueManager.state_tracker[3]:
			DialogueManager.play_dialog(self, 3)
		elif DialogueManager.state_tracker[2]:
			add_to_group("Enemy")
			DialogueManager.play_dialog(self, 2)
		else:
			if not has_talked:
				DialogueManager.play_dialog(self, 1)
				has_talked = true
			else:
				DialogueManager.play_dialog(self, 6)



func _ready():
	super._ready()
	for c in deck_template:
		deck.push_back(c)

func _physics_process(delta):
	handle_animation()


func enemy_choice(combatants):
	var choice = {"target" : -1,
	"action" : "pass"}
	var discard = -1
	#Choosing Card
	for c in range(len(hand)):
		match(hand[c]):
			"Ice Shard":
				if MP > 1:
					choice["action"] = "Ice Shard"
					discard = c
					break
			"Chill":
				if randi()%2 == 0:
					choice["action"] = "Chill"
					discard = c
					break
			"Cooldown":
				if randi()%2 == 0:
					choice["action"] = "Cooldown"
					discard = c
					break
			"Frost":
				if MP > 0:
					choice["action"] = "Frost"
					discard = c
					break
	
	#Choosing Target
	match(choice["action"]):
		"Frost","Ice Shard":
			for c in range(len(combatants)):
				#Enemy will find the character with the highest HP and attack them
				var highHP = 0
				if combatants[c].is_in_group("Ally"):
					if combatants[c].HP > highHP:
						choice["target"] = c
						highHP = combatants[c].HP
		"Chill":
			for c in range(len(combatants)):
				#Enemy will find the character with the highest HP and attack them
				var highHP = 0
				if combatants[c].is_in_group("Ally"):
					if combatants[c].HP > highHP:
						choice["target"] = c
						highHP = combatants[c].HP
		"Cooldown":
			var target = []
			for c in range(len(combatants)):
				if combatants[c].is_in_group("Enemy") and not combatants[c].is_dead:
					target.push_back(c)
			choice["target"] = target[randi_range(0,len(target) - 1)]
	if discard >= 0:
		hand.pop_at(discard)
	return choice
	
func on_death_post_battle():
	DialogueManager.state_tracker[3] = true
