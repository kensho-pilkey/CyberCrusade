extends Node2D

var event = false
var spawn_count = 0
var enemy_total = 10
var kill_count = 0
enum type {S_DROID, B_DROID, DRONE, VIRUS, WORM, HORSE}
var center_pos: Vector2
var timer
var scene_change
	
func _ready():
	scene_change = Timer.new()
	add_child(scene_change)
	scene_change.wait_time = 3
	scene_change.timeout.connect(_on_theme_change_timeout)
	$AnimationPlayer.play("RESET")
	
func _process(delta):
	if enemy_total == spawn_count and not timer.is_stopped():
		timer.stop()
	if enemy_total == kill_count and event:
		end_event()

func start_event():
	event = true
	#$event_light1.visible = true
	$event_light2.visible = true
	#$event_light1.color = "930000"
	$event_light2.color = "930000"
	center_pos = $portal.global_position
	$portal.set_red()
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1
	timer.autostart = true
	timer.timeout.connect(_on_Timer_timeout)
	timer.start()
	
func end_event():
	#$event_light1.color = "316afa"
	$event_light2.visible = false
	$portal.set_blue()
	event = false
	
func _on_Timer_timeout():
	spawn_count += 1
	var num = randi_range(1, 4)
	var enemy_instance
	match num:
		1:
			enemy_instance = load("res://Scenes/sword_droid.tscn").instantiate()
		2:
			enemy_instance = load("res://Scenes/drone.tscn").instantiate()
		3:
			enemy_instance = load("res://Scenes/virus.tscn").instantiate()
		4:
			enemy_instance = load("res://Scenes/bullet_droid.tscn").instantiate()
	add_child(enemy_instance)
	enemy_instance.global_position = center_pos + Vector2(randi_range(-50, 50), randi_range(0, -500))
	enemy_instance.connect("enemy_death", _on_enemy_death)

func _on_enemy_death():
	kill_count += 1


func _on_portal_body_entered(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("fade_out")
		scene_change.start()


func _on_portal_body_exited(body):
	$AnimationPlayer.play("RESET")
	scene_change.stop()
	

func _on_theme_change_timeout():
	Global11.nextWorld()
