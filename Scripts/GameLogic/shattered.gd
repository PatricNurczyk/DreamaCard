extends Node2D
@onready var polygon_2d = $Polygon2D

var shatter : PolygonFracture
var shards : Array
var shard_scenes : Array
var shardScene = preload("res://Scenes/GameLogic/Shard.tscn")
var shard_color : Color = Color(1,1,1,1)
var invert = false
signal shatter_ready
signal done
@onready var unstable = $unstable


func _ready():
	$AudioStreamPlayer2D.pitch_scale = randf_range(1,1.2)
	shatter = PolygonFracture.new()
	shards = shatter.fractureDelaunayRectangle(polygon_2d.polygon,polygon_2d.global_transform,40,1)
	for entry in shards:
		#var texture_info : Dictionary = {"texture" : polygon_2d.texture, "rot" : polygon_2d.texture_rotation, "offset" : polygon_2d.texture_offset, "scale" : polygon_2d.texture_scale}
		var shard = shardScene.instantiate()
		shard.get_node("Polygon").polygon = entry["shape"]
		shard.get_node("Polygon").color = shard_color
		if invert:
			shard.flip = true
		add_child(shard)
		shard_scenes.push_back(shard)
	polygon_2d.queue_free()
	$AnimationPlayer.play("fade")
	unstable.play()
	
func _process(delta):
	pass
	
func fire():
	shatter_ready.emit()
	unstable.stop()
	$AudioStreamPlayer2D.play()
	for s in shard_scenes:
		s.shoot()
	await get_tree().create_timer(.5).timeout
	done.emit()

func _on_animation_player_animation_finished(anim_name):
	pass

func _on_audio_stream_player_2d_finished():
	queue_free()
