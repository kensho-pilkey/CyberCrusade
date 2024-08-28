extends Node

var i = 0 #for testing
var levels = [1, 2]
var level_paths = {1: "res://Scenes/level_1.tscn", 2: "res://Scenes/level_2.tscn"}

func setArray():
	randomize()
	levels.shuffle()

func restart():
	get_tree().change_scene_to_file(level_paths[levels[i]])
	
func nextWorld():
	if i < 2:
		get_tree().change_scene_to_file(level_paths[levels[i]])
	else:
		get_tree().change_scene_to_file("res://Scenes/boss_fight.tscn")
	i += 1
func get_current():
	return i
