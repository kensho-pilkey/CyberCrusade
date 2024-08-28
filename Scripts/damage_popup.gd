extends Label

var fade_out_time = 1.0
var move_distance = Vector2(0, -50) # Move up
var move_speed = 100.0
var animation_player

func _ready():
	animation_player = $AnimationPlayer
	animation_player.play("PopUpAnimation")
	queue_free_after(fade_out_time)

func start(damage: int):
	text = str(damage)
	


func queue_free_after(seconds):
	await(get_tree().create_timer(seconds).timeout)
	queue_free()


func _on_animation_player_animation_finished(anim_name):
	pass 
