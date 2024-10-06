extends Node

var current_map : String = "Test_Map"
var spawn_point : int = 0

#Character Data
var playerData = {
	"Player": {
		"MaxHP" : 100,
		"HP" : 100,
		"MaxMP" : 2,
		"Speed" : 10,
		"Deck" : ["Ember","Ember","Ember","Ember","Ember","Ember","Frost"],
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
