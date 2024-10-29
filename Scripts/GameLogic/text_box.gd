extends MarginContainer
@onready var timer = $LetterDisplayTimer
@onready var label = $MarginContainer/Label

const MAX_WIDTH : int = 256

var text : String= ""
var letter_index = 0
var letter_time = 0.03
var space_time = 0.06
var punct_time = 0.2

signal finished

func display_text(text_display : String):
	text = text_display
	label.text = text_display
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized
		await resized
		custom_minimum_size.y = size.y
		
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	label.text = ""
	display_letter()
	
func display_letter():
	label.text += text[letter_index]
	letter_index += 1
	if letter_index >= len(text):
		finished.emit()
		return
	match(text[letter_index]):
		".","!",",","?":
			timer.wait_time = punct_time
		" ":
			timer.wait_time = space_time
		_:
			timer.wait_time = letter_time
	timer.start()
	await timer.timeout
	display_letter()
