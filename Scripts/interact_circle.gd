extends Area2D

var player_nearby = false
var player
var progress = 0
var complete = false

func _ready():
	player = get_parent().get_node("player")


func _process(delta):
	if !complete:
		if progress >= 100:
			complete = true
			get_parent().start_event()
		if abs(player.global_position.x - global_position.x) < 100:
			player_nearby = true
			visible = true
		else:
			player_nearby = false
			visible = false
		if player_nearby and Input.is_action_pressed("interact"):
			progress += 1
		if Input.is_action_just_released("interact"):
			progress = 0
		$TextureProgressBar.value = progress
	else:
		visible = false
		
		
