extends CharacterBody2D

var state: String
var player
var distance
var direction: Vector2

func _ready():
	player = get_parent().get_node("player")
	
func _process(_delta):
	distance = player.global_position - global_position
	if abs(distance.x) + abs(distance.y) < 3000:
		direction = distance.normalized()
		velocity = direction * 300
		move_and_slide()
	else: global_position = player.global_position
	
	
