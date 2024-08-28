extends Node2D

func _ready():
	$AnimatedSprite2D.play("default")
func _on_quit_pressed():
	get_tree().quit()


func _on_play_pressed():
	Global11.setArray()
	get_tree().change_scene_to_file("res://Scenes/cutscene.tscn")


func _on_play_mouse_entered():
	$play.modulate = Color(0, 5, 100, 1)


func _on_play_mouse_exited():
	$play.modulate = Color(100, 100, 100, 1)

func _on_quit_mouse_entered():
	$quit.modulate = Color(0, 5, 100, 1)


func _on_quit_mouse_exited():
	$quit.modulate = Color(100, 100, 100, 1)
