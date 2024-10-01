extends EntityCharacter

func _physics_process(delta):
	handle_animation()


func enemy_choice(combatants):
	var choice = {"target" : -1,
	"action" : "pass"}
	var discard = -1
	#Choosing Card
	for c in range(len(hand)):
		match(hand[c]):
			"Frost":
				if MP > 0:
					choice["action"] = "Frost"
					discard = c
					break
	
	#Choosing Target
	for c in range(len(combatants)):
		match(choice["action"]):
			"Frost":
				#Enemy will find the character with the highest HP and attack them
				var highHP = 0
				if combatants[c].is_in_group("Ally"):
					if combatants[c].HP > highHP:
						choice["target"] = c
						highHP = combatants[c].HP
	if discard >= 0:
		hand.pop_at(discard)
	return choice
