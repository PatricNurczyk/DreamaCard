extends Node2D
const PLAYERTEMPLATE = preload("res://Scenes/Entities/Player.tscn")
const COMBATCREATOR = preload("res://Scenes/GameLogic/CombatCreator.tscn")
const INIT_ALLY = preload("res://Scenes/GameLogic/Initiative_ally.tscn")
const INIT_ENEMY = preload("res://Scenes/GameLogic/Initiative_enemy.tscn")
const SHATTER = preload("res://Scenes/GameLogic/shattered.tscn")
const UI_POSITIONS = [Vector2(50,-58),Vector2(30,-65),Vector2(5,-70),Vector2(-15,-70),Vector2(-35,-65),Vector2(-60,-58),Vector2(-80,-48)]
const UI_ROTATIONS = [25.0,17.5,10.0,0,-10.0,-17.5,-25.0]
const UI_PASS = Vector2(-50,10)
const UI_READYBREAK = Vector2(10,-30)
const ENEMY_UI_READYBREAK = Vector2(-37.5,-25)
@onready var ally_initiative = $"Initiative Tracker/Ally Initiative"
@onready var enemy_initiative = $"Initiative Tracker/Enemy Initiative"
@onready var battle_veil = $Battle
const SPEED = 7.0
@onready var screen_dim = $CanvasLayer/AnimationPlayer
@onready var camera = $Camera
@onready var combat_text = $"Initiative Tracker/CombatText"
var text_combat : String = ""
var player : CharacterBody2D
var map : MapTemplate
var camera_zoom : float = 5
var camera_pos : Vector2
var camera_speed : float = 3
@onready var card_ui = $Cards
@onready var pass_ui = $Cards/Pass
@onready var cancel = $cancel
@onready var select = $select
@onready var battle_music = $battleMusic

enum gameStates {explore, combat, cutscene, transition}
var currState = gameStates.explore


#Combat variables
enum combatStates {idle, allyTurn, target, enemyTurn, animation}
var combatState : int = combatStates.idle
var battleground
var combatants : Array = []
var combatants_position : Array = []
var initiative : Array = []
var init_ui : Array = []
var allyCount : int = 0
var enemyCount : int = 0
var currTurn : int = 0
var veilSize : int = 0
var hand_ui : Array = []
var card_select : int = -1 
var target : int = -1
var target_type : int = -1
var past_positions : Array = []
var shatter
var acc_result
var pause_position  : float = 0
# Called when the node enters the scene tree for the first time.
signal action_completed

func _input(event):
	if Input.is_action_just_pressed("Cancel") and combatState == combatStates.target:
		shatter.queue_free()
		pass_ui.cancel()
		for c in hand_ui:
			c.cancel()
		for c in combatants:
			c.name_ui.visible = false
		card_select = 	-1
		camera_zoom = 5
		camera.position = combatants[currTurn].position
		cancel.play()
		init_ui[currTurn].changeWhite()
		init_ui[currTurn].initiative = 100
		text_combat = ""
		combatants[currTurn].is_idle = true
		combatState = combatStates.allyTurn
		battle_music.set_bus("Master")
	if Input.is_action_just_pressed("Click") and combatState == combatStates.target:
		var nearest_distance = 20
		var mouse = get_local_mouse_position()
		for i in range(len(combatants)):
			var distance = combatants[i].position.distance_to(mouse)
			if distance < nearest_distance:
				nearest_distance = distance
				target = i
		if target >= 0:
			match(target_type):
				0:
					if combatants[target].is_in_group("Enemy") or combatants[target].is_dead:
						cancel.play()
						combatState = combatStates.target
						return
				1:
					if combatants[target].is_in_group("Ally"):
						cancel.play()
						combatState = combatStates.target
						return
					if combatants[target].is_dead:
						cancel.play()
						combatState = combatStates.target
						return
				2:
					if combatants[target].is_in_group("Ally"):
						cancel.play()
						combatState = combatStates.target
						return
					if combatants[target].is_dead:
						cancel.play()
						combatState = combatStates.target
						return
				3:
					if combatants[target].is_in_group("Enemy"):
						cancel.play()
						combatState = combatStates.target
						return
			select.play()
			battle_music.set_bus("Master")
			for i in init_ui:
				if i.buff_ui:
					i.buff_ui.despawn()
					i.buff_ui = null
			for c in combatants:
				c.name_ui.visible = false
			combatState = combatStates.animation
			text_combat = hand_ui[card_select].SkillName
			shatter.fire()
			combatants[currTurn].sprite.play("attack_break")
			await shatter.done
			var accuracy = await combatants[currTurn].check_accuracy(hand_ui[card_select].accuracy, hand_ui[card_select].element, hand_ui[card_select].is_attack)
			hand_ui[card_select].execute_action(self, accuracy)
			init_ui[currTurn].changeWhite()
			await action_completed
			for c in range(len(card_ui.get_children())):
				if not card_ui.get_child(c).is_in_group("pass_card"):
					card_ui.get_child(c).queue_free()
			print(card_select)
			if card_select > 0:
				if not acc_result:
					combatants[currTurn].deck.push_back(combatants[currTurn].hand[card_select - 1])
				combatants[currTurn].hand.pop_at(card_select - 1)
			target = -1
			hand_ui = []
			text_combat = ""
			next_turn()
func _ready():
	load_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	combat_text.text = "[center][font_size=60]" + text_combat + "[/font_size][/center]"
	camera.zoom = camera.zoom.lerp(Vector2(camera_zoom,camera_zoom), 3 * delta)
	battle_veil.scale = battle_veil.scale.lerp(Vector2(veilSize,veilSize), 10 * delta)
	for c in combatants:
		c.velocity = Vector2.ZERO
	for c in range(len(init_ui)):
		init_ui[c].maxHP = combatants[c].maxHP
		init_ui[c].maxMP = combatants[c].maxMP
		init_ui[c].HP = combatants[c].HP
		init_ui[c].MP = combatants[c].MP
	if currState == gameStates.explore:
		camera.position = player.position
		player.can_walk = true
		battle_music.volume_db = move_toward(battle_music.volume_db, -60, 40 * delta)
	elif currState == gameStates.transition:
		if player:
			player.can_walk = false
	elif currState == gameStates.combat:
		battle_music.volume_db = move_toward(battle_music.volume_db, -15, 40 * delta)
		for i in range(len(combatants)):
			var t = delta * SPEED
			combatants[i].global_position = lerp(combatants[i].global_position, combatants_position[i],t)
		if combatState == combatStates.allyTurn:
			pass_ui.scale = lerp(pass_ui.scale, Vector2(1,1), 20 * delta)
			pass_ui.position = lerp(pass_ui.position, UI_PASS, 20 * delta)
			var idx = 0
			while idx < len(hand_ui):
				if hand_ui[idx].discarded:
					hand_ui.pop_at(idx)
					combatants[currTurn].hand.pop_at(idx - 1)
					print(combatants[currTurn].hand)
				else:
					idx += 1
			for i in range(len(hand_ui)):
				hand_ui[i].scale = lerp(hand_ui[i].scale, Vector2(1,1), 20 * delta)
				hand_ui[i].position = lerp(hand_ui[i].position, UI_POSITIONS[i], 20 * delta)
				if hand_ui[i].centered:
					hand_ui[i].rotation_degrees = lerp(hand_ui[i].rotation_degrees,0.0,20 * delta)
				else:
					hand_ui[i].rotation_degrees = lerp(hand_ui[i].rotation_degrees,float(UI_ROTATIONS[i]),20 * delta)
		elif combatState == combatStates.target:
			pass_ui.scale = lerp(pass_ui.scale, Vector2.ZERO, 20 * delta)
			pass_ui.position = lerp(pass_ui.position, Vector2.ZERO, 20 * delta)
			for i in range(len(hand_ui)):
				hand_ui[i].rotation_degrees = lerp(hand_ui[i].rotation_degrees,0.0,20 * delta)
				if i != card_select:
					hand_ui[i].scale = lerp(hand_ui[i].scale, Vector2.ZERO, 20 * delta)
					hand_ui[i].position = lerp(hand_ui[i].position, Vector2.ZERO, 20 * delta)
				else:
					hand_ui[i].position = lerp(hand_ui[i].position, UI_READYBREAK, 20 * delta)
	
	
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
	player.name = PlayerInfo.player_name
	PlayerInfo.load_player_data(player)
	var map_scene = load("res://Scenes/Maps/" + PlayerInfo.current_map + ".tscn")
	map = map_scene.instantiate()
	add_child(map)
	add_child(player)
	pause_position = 0
	battle_music.stream = map.battle_music
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
		body.collider.z_index = 2
		if body.collider.is_in_group("Ally"):
			body.collider.can_walk = false
			body.collider.velocity = Vector2.ZERO
			body.collider.HP = body.collider.maxHP
			combatants.push_back(body.collider)
			initiative.push_back(100 - body.collider.speed)
			var ui = INIT_ALLY.instantiate()
			ui.barName = body.collider.name
			ui.initiative = body.collider.speed
			ui.character = body.collider
			init_ui.push_back(ui)
			ally_initiative.add_child(ui)
			combatants_position.push_back(battleground.get_child(allyCount).global_position)
			allyCount += 1
			body.collider.direction = "right"
			print(combatants[-1].deck)
			combatants[-1].deck.clear()
			for c in PlayerInfo.playerData[body.collider.name]["Deck"]:
				combatants[-1].deck.push_back(c)
			#body.collider.deck = PlayerInfo.playerData[body.collider.name]["Deck"]
			combatants[-1].deck.shuffle()
			combatants[-1].hand.clear()
			combatants[-1].MP = 0
			past_positions.push_back(combatants[-1].position)
			combatants[-1].get_node("CollisionShape2D").visible = false
		elif body.collider.is_in_group("Enemy"):
			if enemyCount >= 5:
				body.collider.queue_free()
				continue
			body.collider.speed += randi_range(-3,3)
			combatants.push_back(body.collider)
			initiative.push_back(100 - body.collider.speed)
			var ui = INIT_ENEMY.instantiate()
			ui.barName = body.collider.name
			ui.initiative = body.collider.speed 
			ui.character = body.collider
			print(body.collider.deck)
			body.collider.deck.shuffle()
			body.collider.hand.clear()
			enemy_initiative.add_child(ui)
			init_ui.push_back(ui)
			combatants_position.push_back(battleground.get_child(enemyCount + 4).global_position)
			enemyCount += 1
			body.collider.direction = "left"
	camera.position = battleground.position
	battle_veil_on()
	camera_zoom = 3.5
	battle_music.play(pause_position)
	await get_tree().create_timer(1.5).timeout
	for c in combatants:
		c.in_combat = true
	next_turn()
	
	
	
#COMBAT FUNCTIONS
func battle_veil_on():
	battle_veil.position = player.position
	veilSize = 10
func battle_veil_off():
	veilSize = 0
func find_next():
	var min_init = 1000
	var index = 0
	for i in range(len(initiative)):
		if initiative[i] < min_init:
			if not combatants[i].is_dead:
				index = i
				min_init = initiative[i]
	for i in range(len(initiative)):
		if combatants[i].is_dead:
			initiative[i] = 100
			for e in combatants[i].buffs.get_children():
				e.fire()
			for e in combatants[i].dots.get_children():
				e.fire()
		else:
			initiative[i] -= min_init
		init_ui[i].initiative = 100 - initiative[i]
	initiative[index] = 100 - combatants[index].speed
	init_ui[index].initiative = 100
	return index
	
	
func next_turn():
	#Checking if the fight is over
	var allies = []
	var enemies = []
	for c in combatants:
		if c.is_in_group("Ally"):
			allies.push_back(c)
		else:
			enemies.push_back(c)
	var alliesOnField = false
	var enemiesOnField = false
	for a in allies:
		if not a.is_dead:
			alliesOnField = true
	for e in enemies:
		if not e.is_dead:
			enemiesOnField = true
	if not enemiesOnField:
		end_combat(enemies)
		return
	if not alliesOnField:
		print("Game Over")
		get_tree().quit()
	currTurn = find_next()
	for i in range(len(init_ui)):
		if i == currTurn:
			init_ui[i].text.modulate = Color("00ff00")
		else:
			init_ui[i].text.modulate = Color("ffffff")
	draw_card(combatants[currTurn])
	combatants[currTurn].MP = min(combatants[currTurn].MP + 1, combatants[currTurn].maxMP)
	camera_zoom = 5
	if combatants[currTurn].is_in_group("Ally"):
		camera.position = combatants[currTurn].position + Vector2(0,-20)
		await combatants[currTurn].check_turn()
		if combatants[currTurn].is_dead:
			next_turn()
			return
		if combatants[currTurn].is_stun:
			combatants[currTurn].is_stun = false
			next_turn()
			return
		ally_turn()
	else:
		camera.position = combatants[currTurn].position + Vector2(0,-10)
		await combatants[currTurn].check_turn()
		if combatants[currTurn].is_dead:
			next_turn()
			return
		if combatants[currTurn].is_stun:
			combatants[currTurn].is_stun = false
			next_turn()
			return
		enemy_turn()
		
func draw_card(character):
	while len(character.deck) > 0 and len(character.hand) < 6:
		character.hand.push_back(character.deck.pop_front())
func ally_turn():
	pass_ui.cancel()
	combatState = combatStates.allyTurn
	card_ui.position = combatants[currTurn].position
	var weapon = load("res://Scripts/Equipment/Weapons/" + PlayerInfo.playerData[combatants[currTurn].name]["Equipment"]["Weapon"] + ".gd").new()
	var weapon_card = weapon.attackCard
	hand_ui.push_back(weapon_card.instantiate())
	
	weapon.queue_free()
	for i in range(len(combatants[currTurn].hand)):
		var cardbutton = load("res://Scenes/Cards/" + combatants[currTurn].hand[i] + ".tscn").instantiate()
		hand_ui.push_back(cardbutton)
	for c in hand_ui:
		c.scale = Vector2.ZERO
		if combatants[currTurn].MP < c.mpCost:
			c.grey_out()
		card_ui.add_child(c)
	card_ui.move_child(pass_ui,-1)
	await get_tree().create_timer(.5).timeout
	
func select_target(node_index):
	if combatState == combatStates.target:
		return
	combatState = combatStates.target
	pass_ui.no_hover = true
	for c in hand_ui:
		c.no_hover = true
	select.play()
	init_ui[currTurn].changeYellow()
	init_ui[currTurn].initiative = min(100, combatants[currTurn].speed + hand_ui[node_index].initiative)
	combatants[currTurn].is_idle = false
	combatants[currTurn].sprite.play("prep_attack")
	camera_zoom = 4.5
	camera.position = battleground.position
	card_select = node_index
	target_type = hand_ui[node_index].target_type
	hand_ui[node_index].card_selected()
	match(target_type):
		0:
			text_combat = "Select an Ally"
			for c in combatants:
				if c.is_in_group("Ally") and not c.is_dead:
					c.name_ui.visible = true
		1:
			text_combat = "Select a Target"
			for c in combatants:
				if c.is_in_group("Enemy") and not c.is_dead:
					c.name_ui.visible = true
		2: 
			text_combat = "Select Target to Confirm"
			for c in combatants:
				if c.is_in_group("Enemy") and not c.is_dead:
					c.name_ui.visible = true
		3:
			text_combat = "Select an Ally"
			for c in combatants:
				if c.is_in_group("Ally"):
					c.name_ui.visible = true
					
	shatter = SHATTER.instantiate()
	match (hand_ui[card_select].element):
		"fire":
			shatter.shard_color = Color("ff5b17")
		"frost":
			shatter.shard_color = Color("11ffff")
		"earth":
			shatter.shard_color = Color('3a5f00')
		"lightning":
			shatter.shard_color = Color("c8ba00")
		"void":
			shatter.shard_color = Color("#8e43f7")
		"light":
			shatter.shard_color = Color("#f5ff69")
		"arcane":
			shatter.shard_color = Color("#4fffbe")
	shatter.position = UI_READYBREAK + Vector2(15.5,23)
	card_ui.add_child(shatter)
	await get_tree().create_timer(.2).timeout
	battle_music.set_bus("Muffle")
	await shatter.shatter_ready
	hand_ui[card_select].modulate = Color("ffffff00")

func pass_turn():
	combatState = combatStates.animation
	target = -1
	pass_ui.scale = Vector2.ZERO
	pass_ui.position = Vector2.ZERO
	for c in range(len(card_ui.get_children()) - 1):
		card_ui.get_child(c).queue_free()
	hand_ui = []
	init_ui[currTurn].changeWhite()
	text_combat = ""
	next_turn()

func enemy_turn():
	await get_tree().create_timer(.5).timeout
	var choice = combatants[currTurn].enemy_choice(combatants)
	if choice["action"] == "pass":
		text_combat = "Pass"
		await get_tree().create_timer(.5).timeout
		text_combat = ""
	else:
		target = choice["target"]
		var card = load("res://Scenes/Cards/" + choice["action"] + ".tscn").instantiate()
		card.get_node("Card").scale = Vector2.ZERO
		card.card_selected()
		card.position = ENEMY_UI_READYBREAK
		shatter = SHATTER.instantiate()
		match (card.element):
			"fire":
				shatter.shard_color = Color("ff5b17")
			"frost":
				shatter.shard_color = Color("11ffff")
			"earth":
				shatter.shard_color = Color('3a5f00')
			"lightning":
				shatter.shard_color = Color("c8ba00")
			"void":
				shatter.shard_color = Color("#8e43f7")
			"light":
				shatter.shard_color = Color("#f5ff69")
			"arcane":
				shatter.shard_color = Color("#4fffbe")
		shatter.position = Vector2(15.5,23)
		shatter.invert = true
		combatants[currTurn].add_child(card)
		await get_tree().create_timer(.2).timeout
		card.add_child(shatter)
		combatants[currTurn].is_idle = false
		combatants[currTurn].sprite.play("prep_attack")
		await combatants[currTurn].sprite.animation_finished
		card.get_node("Card").modulate = Color("ffffff00")
		shatter.fire()
		combatants[currTurn].sprite.play("attack_break")
		await shatter.done
		text_combat = choice["action"]
		var t_type = card.target_type
		var card_script = card.card_script.new()
		var accuracy = await combatants[currTurn].check_accuracy(card.accuracy, card.element, card.is_attack)
		match(t_type):
			0:
				card_script.execute_action(self,accuracy)
			1:
				card_script.execute_action(self,accuracy)
			2: 
				card_script.execute_action(self,accuracy)
			3:
				pass
				
		combatState = combatStates.animation
		await action_completed
		target = -1
		text_combat = ""
		card.queue_free()
	next_turn()

func end_combat(enemies):
	camera.position = battleground.position
	camera_zoom = 5
	await get_tree().create_timer(.5).timeout
	for e in enemies:
		combatants.erase(e)
		e.queue_free()
	for i in init_ui:
		i.queue_free()
	init_ui.clear()
	combatants_position.clear()
	for p in past_positions:
		combatants_position.push_back(p)
	battle_veil_off()
	for c in combatants:
		c.clean_effects()
	await get_tree().create_timer(1).timeout
	for c in combatants:
		c.z_index = 0
		c.in_combat = false
		c.get_node("CollisionShape2D").visible = true
	combatants.clear()
	initiative.clear()
	past_positions.clear()
	combatants_position.clear()
	battleground.queue_free()
	currState = gameStates.explore
	pause_position = battle_music.get_playback_position()
