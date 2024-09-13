extends Node2D

@export var map : String
@export var spawn_point : int


# Called when the node enters the scene tree for the first time.
func _ready():
	if map == null:
		print("SCENE NOT LOADED")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func transition_trigger(body):
	if body.is_in_group("Player"):
		PlayerInfo.current_map = map
		PlayerInfo.spawn_point = spawn_point
		get_parent().get_parent().load_map()
