extends Node2D
const PLAYERTEMPLATE = preload("res://Scenes/Entities/Player.tscn")
const COMBATCREATOR = preload("res://Scenes/GameLogic/CombatCreator.tscn")
const INIT_ALLY = preload("res://Scenes/GameLogic/Initiative_ally.tscn")
const INIT_ENEMY = preload("res://Scenes/GameLogic/Initiative_enemy.tscn")
const UI_POSITIONS = [Vector2(30,-60)]
@onready var ally_initiative = $"Initiative Tracker/Ally Initiative"
@onready var enemy_initiative = $"Initiative Tracker/Enemy Initiative"
@onready var battle_veil = $Battle
const SPEED = 7.0
@onready var screen_dim = $CanvasLayer/AnimationPlayer
@onready var camera = $Camera
@onready var animation_player = $CardUI/AnimationPlayer

var player : CharacterBody2D
var map : MapTemplate
var camera_zoom : float = 5
var camera_pos : Vector2
var camera_speed : float = 3
@onready var card_ui = $CardUI

enum gameStates {explore, combat, cutscene, transition}
var currState = gameStates.explore


#Combat variables
enum combatStates {allyTurn, target, enemyTurn}
var combatState : int
var battleground
var combatants : Array = []
var combatants_position : Array = []
var initiative : Array = []
var initiative_ui : Array = []
var allyCount : int = 0
var enemyCount : int = 0
var currTurn : int = 0
var veilSize : int = 0
var deck : Dictionary = {}
var hand : Dictionary = {}
var hand_ui : Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	load_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera.zoom = camera.zoom.lerp(Vector2(camera_zoom,camera_zoom), 3 * delta)
	battle_veil.scale = battle_veil.scale.lerp(Vector2(veilSize,veilSize), .5 * delta)
	if currState == gameStates.explore:
		camera.position = player.position
		player.can_walk = true
	elif currState == gameStates.transition:
		if player:
			player.can_walk = false
	elif currState == gameStates.combat:
		for i in range(len(combatants)):
			var t = delta * SPEED
			combatants[i].position = lerp(combatants[i].position, combatants_position[i],t)
	
	
func load_map():
	if currState == gameStates.transition:
		return
	currState = gameStates.transition
	screen_dim.play("dim_in")
	await get_tree().create_timer(.5).timeout
	if map:
		remove_child(map)
		map.queue_free()
	if player:
		remove_child(player)
		player.queue_free()
	player = PLAYERTEMPLATE.instantiate()
	PlayerInfo.load_player_data(player)
	var map_scene = load("res://Scenes/Maps/" + PlayerInfo.current_map + ".tscn")
	map = map_scene.instantiate()
	add_child(map)
	add_child(player)
	player.position = map.SpawnPoints[PlayerInfo.spawn_point]
	player.direction = map.Directions[PlayerInfo.spawn_point]
	camera.position = player.position
	player.velocity = Vector2.ZERO
	await get_tree().create_timer(.5).timeout
	screen_dim.play("dim_out")
	currState = gameStates.explore
	
	
func start_combat():
	allyCount = 0
	enemyCount = 0
	if currState == gameStates.combat:
		return
	currState = gameStates.combat
	battleground = COMBATCREATOR.instantiate()
	battleground.position = player.position
	add_child(battleground)
	var space := get_world_2d().direct_space_state
	var search = PhysicsShapeQueryParameters2D.new()
	search.transform = player.global_transform
	var shape = CircleShape2D.new()
	shape.radius = 120
	search.shape = shape
	var bodies = space.intersect_shape(search)
	for body in bodies:
		if body.collider.is_in_group("Ally"):
			combatants.push_back(body.collider)
			initiative.push_back(100 - body.collider.speed)
			var ui = INIT_ALLY.instantiate()
			ui.barName = body.collider.name
			ui.initiative = body.collider.speed
			ally_initiative.add_child(ui)
			combatants_position.push_back(battleground.get_child(allyCount).global_position)
			allyCount += 1
			body.collider.direction = "right"
			deck[body.collider.name] = PlayerInfo.playerData[body.collider.name]["Deck"]
			deck[body.collider.name].shuffle()
			hand[body.collider.name] = []
		elif body.collider.is_in_group("Enemy"):
			combatants.push_back(body.collider)
			initiative.push_back(100 - body.collider.speed)
			var ui = INIT_ENEMY.instantiate()
			ui.barName = body.collider.name
			ui.initiative = body.collider.speed
			enemy_initiative.add_child(ui)
			combatants_position.push_back(battleground.get_child(enemyCount + 4).global_position)
			enemyCount += 1
			body.collider.direction = "left"
	camera.position = battleground.position
	battle_veil_on()
	camera_zoom = 3.5
	
	await get_tree().create_timer(1.5).timeout
	next_turn()
	
	
	
#COMBAT FUNCTIONS
func battle_veil_on():
	battle_veil.position = player.position
	veilSize = 100
	print_tree()
func battle_veil_off():
	veilSize = 0
func find_next():
	var min_init = 1000
	var index = 0
	for i in range(len(initiative)):
		if initiative[i] < min_init:
			index = i
			min_init = initiative[i]
	for i in range(len(initiative)):
		initiative[i] -= min_init
	initiative[index] = 100 - combatants[index].speed
	return index
	
	
func next_turn():
	currTurn = find_next()
	camera_zoom = 5
	if combatants[currTurn].is_in_group("Ally"):
		camera.position = combatants[currTurn].position + Vector2(0,-20)
		ally_turn()
	else:
		camera.position = combatants[currTurn].position + Vector2(0,-10)
		enemy_turn()
		
func draw_card(character):
	while len(deck[character.name]) > 0 or len(hand[character.name]) < 6:
		hand[character.name].push_back(deck[character.name].pop_front())
func ally_turn():
	draw_card(combatants[currTurn])
	var weapon = load("res://Scripts/Equipment/Weapons/" + PlayerInfo.playerData[combatants[currTurn].name]["Equipment"]["Weapon"] + ".gd").new()
	var weapon_card = weapon.attackCard
	card_ui.get_child(0).add_child(weapon_card.instantiate())
	weapon.queue_free()
	for i in range(len(hand[combatants[currTurn].name])):
		var cardbutton = load("res://Scenes/Cards/" + hand[combatants[currTurn].name][i] + ".tscn").instantiate()
		card_ui.get_child(i+1).add_child(cardbutton)
	await get_tree().create_timer(.5).timeout
	animation_player.play("CardsFlyOut")
func enemy_turn():
	pass
