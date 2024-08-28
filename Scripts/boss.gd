extends CharacterBody2D

enum states {SMASH, LASER, IDLE, SUMMON, DEATH}

var player
var health = 1000
var speed = 500
var height_above_player = 800
var boss_state = states.IDLE
var state_timer = Timer.new()
var spawn_timer = Timer.new()
var spawn_pos = Vector2(0,0)

func _ready():
	add_to_group("enemy")
	
	deactive_smash()
	deactive_laser()
	spawn_pos = position
	player = get_parent().get_node("player")
	
	add_child(state_timer)
	state_timer.autostart = true
	state_timer.wait_time = 5
	state_timer.timeout.connect(_on_State_Timer_timeout)
	state_timer.start()
	
	add_child(spawn_timer)
	spawn_timer.wait_time = 1
	spawn_timer.autostart = false
	spawn_timer.timeout.connect(_on_Spawn_Timer_timeout)
	
	
func _process(delta):
	var target_position = Vector2(0,0)
	var direction
	if boss_state == states.SMASH:
		$AnimatedSprite2D.play("smash")
		var offset
		if (player.global_position.x - global_position.x) < 0:
			offset = 550
		else:
			offset = -500
		target_position = Vector2(player.position.x + offset, player.position.y)
		direction = (target_position - position).normalized()
		position += direction * speed * delta * 1.4
		#screen shake
	elif boss_state == states.LASER:
		$AnimatedSprite2D.play("laser")
		if $laser_beam/AnimatedSprite2D.frame == 9:
			$laser_beam/CollisionShape2D.disabled = false
		elif $laser_beam/AnimatedSprite2D.frame == 18:
			$laser_beam/CollisionShape2D.set_deferred("disabled", true)
		target_position = Vector2(player.position.x - 308, player.position.y - height_above_player)
		direction = (target_position - position).normalized()
		position += direction * speed * delta
	elif boss_state == states.IDLE:
		$AnimatedSprite2D.play("idle")
	elif boss_state == states.SUMMON:
		$AnimatedSprite2D.play("summon")
		target_position = Vector2(spawn_pos.x, spawn_pos.y)
		direction = (target_position - position).normalized()
		position += direction * speed * delta
	
	if boss_state == states.DEATH:
		$AnimatedSprite2D.play("death")
		get_parent().get_node("AnimationPlayer").play("fade_out")
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")

	
func _on_State_Timer_timeout():
	var num = randi_range(1, 3)
	spawn_timer.stop()
	deactive_laser()
	deactive_smash()
	#deactivate smash
	match num:
		1:
			boss_state = states.SMASH
		2:
			boss_state = states.LASER
		3:
			boss_state = states.SUMMON
			spawn_timer.start()
			
func _on_Spawn_Timer_timeout():
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
	get_parent().add_child(enemy_instance)
	enemy_instance.global_position = global_position + Vector2(randi_range(-500, 500), randi_range(0, -500))
	

func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "laser":
		if $AnimatedSprite2D.frame == 9:
			activate_laser()
		if $AnimatedSprite2D.frame == 1:
			deactive_laser()
	if $AnimatedSprite2D.animation == "smash":
		if $AnimatedSprite2D.frame == 8:
			deactive_smash()
		elif $AnimatedSprite2D.frame == 5:
			$smash/smash_left.disabled = false
			$smash/smash_right.disabled = false


func activate_laser():
	$laser_beam/AnimatedSprite2D.visible = true
	$laser_beam/AnimatedSprite2D.play("laser")
	$laser_beam/PointLight2D.visible = true
func deactive_laser():
	$laser_beam/AnimatedSprite2D.visible = false
	$laser_beam/AnimatedSprite2D.stop()
	$laser_beam/CollisionShape2D.set_deferred("disabled", true)
	$laser_beam/PointLight2D.visible = false


func deactive_smash():
	$smash/smash_left.set_deferred("disabled", true)
	$smash/smash_right.set_deferred("disabled", true)

func _on_laser_beam_body_entered(body):
	if body.is_in_group("player"):
		body.change_health(-100)


func _on_smash_body_entered(body):
	if body.is_in_group("player"):
		body.change_health(-75)

func take_damage(att):
	$AnimationPlayer.play("hit")
	if att == "1":
		health -= 50
	if att == "2":
		health -= 25
		
	if health < 0:
		health = 0
		boss_state = states.DEATH
	get_parent().get_node("player").get_node("health_bar").value = health
	
	
