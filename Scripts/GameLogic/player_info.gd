extends Node

var current_map : String = "Test_Map"
var spawn_point : int = 0
var player_name = "Patty"

#Character Data
var playerData = {
	"Patty": {
		"MaxHP" : 10,
		"MaxMP" : 2,
		"Speed" : 10,
		"Deck" : ["Focus","Focus","Burn","Dark","Heal","Heal", "Frost","Stone","Quake", "Heat Up","Antimatter","Cooldown","Growth","Heat Up","Shard","Stun","Drain"],
		#"Deck" : ["Drain","Shard","Shard","Burn","Burn","Antimatter","Antimatter","Stun","Stun"],
		#"Deck" : ["Ember","Dark","Frost","Stone", "Heat Up","Heat Up", "Heat Up","Heat Up", "Heat Up","Heat Up", "Heat Up","Heat Up", "Heat Up","Heat Up", "Heat Up","Heat Up"],
		"AltDeck" : [],
		"WeaponTypes": "Shortsword",
		"Equipment": {
			"Head" : null,
			"Body" : null,
			"Boots": null,
			"Weapon": "First_Dream"
		}
	}
}

func load_player_data(player):
	player.maxHP = playerData[player.name]["MaxHP"]
	player.maxMP = playerData[player.name]["MaxMP"]
	player.speed = playerData[player.name]["Speed"]
	player.HP = playerData[player.name]["MaxHP"]
