extends TextureRect

var speed = 800  # Adjust as necessary
var direction = Vector2.RIGHT  # Default direction

func _ready():
	$laser.play()
	add_to_group("laser")
	
func _process(delta):
	position += direction.normalized() * speed * delta

func set_dir(dir):
	direction = dir

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.change_health(-75)
	queue_free()
