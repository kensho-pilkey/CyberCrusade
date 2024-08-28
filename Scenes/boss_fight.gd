extends Node2D


func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3
	timer.timeout.connect(_on_timer_timeout)
	timer.autostart = true
	timer.start()

func _on_timer_timeout():
	var loot_scene = load("res://Scenes/loot.tscn")
	var loot = loot_scene.instantiate()
	get_parent().add_child(loot)
	loot.global_position = $player.global_position + Vector2(randi_range(-100, 100), randi_range(-100, 0))
