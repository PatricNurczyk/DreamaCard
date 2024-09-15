extends EntityCharacter

func _physics_process(delta):
	handle_animation(velocity)
