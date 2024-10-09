extends EntityCharacter

@export var deck_template : Array[String]

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
			"Chill":
				if randi()%2 == 0:
					choice["action"] = "Chill"
					discard = c
					break
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
			"Chill":
				#Enemy will find the character with the highest HP and attack them
				var highHP = 0
				if combatants[c].is_in_group("Ally"):
					if combatants[c].HP > highHP:
						choice["target"] = c
						highHP = combatants[c].HP
	if discard >= 0:
		hand.pop_at(discard)
	return choice
