extends Node2D
@onready var polygon_2d = $Polygon2D

var shatter : PolygonFracture
var shards : Array
var shard_scenes : Array
var shardScene = preload("res://Scenes/GameLogic/Shard.tscn")
var shard_color : Color = Color(.6,.6,.6,1)
var invert = false
signal shatter_ready
signal done
var is_repairing = false
var is_firing = false

var new_pos : Vector2
var element : String
var turns : int
var modifier : String
var value
@onready var icon = $icon
var icon_img

func trigger_effect(damage : int):
	turns -= 1
	var mod = 1 + value
	if turns < 0:
		fire()
	return damage * mod


func _ready():
	$break.pitch_scale = randf_range(1.5,2)
	$repair.pitch_scale = randf_range(1.0,1.5)
	shatter = PolygonFracture.new()
	shards = shatter.fractureDelaunay(polygon_2d.polygon,polygon_2d.global_transform,20,1)
	var color_shard
	match (element):
		"fire":
			shard_color = Color("ff5b17")
		"frost":
			shard_color = Color("11ffff")
		"earth":
			shard_color = Color('3a5f00')
		"lightning":
			shard_color = Color("c8ba00")
		"void":
			shard_color = Color("#8e43f7")
		"light":
			shard_color = Color("#f5ff69")
		"arcane":
			shard_color = Color("#4fffbe")
	for entry in shards:
		var shard = shardScene.instantiate()
		shard.get_node("Polygon").polygon = entry["shape"]
		shard.get_node("Polygon").color = shard_color
		var shard_x = randf_range(50,100) * (1 if randi() % 2 == 0 else -1)
		var shard_y = randf_range(50,100) * (1 if randi() % 2 == 0 else -1)
		shard.position = Vector2(shard_x,shard_y)
		shard.modifier = true
		if randi() % 2 == 0:
			shard.flip = true
		add_child(shard)
		shard_scenes.push_back(shard)
	polygon_2d.queue_free()
	$AnimationPlayer.play("fade")
	$repair.play() 
	icon.texture = icon_img
	await get_tree().create_timer(.1).timeout
	is_repairing = true
	
func _process(delta):
	position.x = move_toward(position.x, new_pos.x, delta * 100)
	position.y = move_toward(position.y, new_pos.y, delta * 100)
	if is_repairing:
		for s in shard_scenes:
			#s.position = lerp(s.position, Vector2.ZERO, delta * 6.5)
			s.position.x = move_toward(s.position.x,0,delta * 200)
			s.position.y = move_toward(s.position.y,0,delta * 200)
func fire():
	if not is_firing:
		is_firing = true
		shatter_ready.emit()
		$break.play()
		icon.queue_free()
		for s in shard_scenes:
			s.shoot()

func _on_animation_player_animation_finished(anim_name):
	pass


func _on_repair_finished():
	is_repairing = false


func _on_break_finished():
	queue_free()
