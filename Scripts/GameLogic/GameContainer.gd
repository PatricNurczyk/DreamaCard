extends Node2D
const PLAYERTEMPLATE = preload("res://Scenes/Entities/Player.tscn")
@onready var screen_dim = $CanvasLayer/AnimationPlayer
@onready var camera = $Camera
var player : CharacterBody2D
var map : MapTemplate
var camera_zoom : float = 3
var camera_pos : Vector2
var camera_speed : float = 3

enum gameStates {explore, combat, cutscene, transition}
var currState = gameStates.explore


# Called when the node enters the scene tree for the first time.
func _ready():
	load_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if currState == gameStates.explore:
		camera.position = player.position
		player.can_walk = true
	elif currState == gameStates.transition:
		if player:
			player.can_walk = false
	
	
	
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
	var map_scene = load("res://Scenes/Maps/" + PlayerInfo.current_map + ".tscn")
	map = map_scene.instantiate()
	add_child(map)
	map.add_child(player)
	player.position = map.SpawnPoints[PlayerInfo.spawn_point]
	player.direction = map.Directions[PlayerInfo.spawn_point]
	camera.position = player.position
	player.velocity = Vector2.ZERO
	await get_tree().create_timer(.5).timeout
	screen_dim.play("dim_out")
	currState = gameStates.explore
