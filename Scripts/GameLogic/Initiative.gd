extends HBoxContainer
@onready var text = $name
@onready var init_bar = $init_bar
@export var barName : String
@export var initiative : int

# Called when the node enters the scene tree for the first time.
func _ready():
	text.text = barName


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	init_bar.value = move_toward(init_bar.value, initiative, delta * 20)
