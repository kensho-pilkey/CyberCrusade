extends Node2D


func _ready():
	$CharacterBody2D/AnimationPlayer.play("cutscene")
	await get_tree().create_timer(13).timeout
	get_tree().change_scene_to_file("res://Scenes/level_0.tscn")
