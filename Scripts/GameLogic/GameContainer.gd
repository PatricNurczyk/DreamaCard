extends Node2D
const PLAYERTEMPLATE = preload("res://Scenes/Entities/Player.tscn")

@onready var camera = $Camera
var player : CharacterBody2D
var map : MapTemplate

enum gameStates {explore, combat, cutscene}
var currState = gameStates.explore


# Called when the node enters the scene tree for the first time.
func _ready():
	player = PLAYERTEMPLATE.instantiate()
	var map_scene = load(PlayerInfo.current_map)
	var map = map_scene.instantiate()
	add_child(map)
	map.add_child(player)
	player.position = map.SpawnPoints[PlayerInfo.spawn_point]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if currState == gameStates.explore:
		camera.position = player.position
