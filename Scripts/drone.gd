extends CharacterBody2D

var speed = 500
var player
var enemy_state = "idle"
var health = 75
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var vertical_follow_distance = 900
var horizontal_follow_distance = 1500
var horizontal_leeway = 50
var vertical_leeway = 50
var attack_range = 200
var attack_timer = Timer.new()
var can_move = true
var is_above_player = false

signal enemy_death

func _ready():
	$hp.value = health
	player = get_parent().get_node("player")  # Ensure this is the correct path to the player node
	add_to_group("enemy")
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	attack_timer.wait_time = 1.0
	attack_timer.one_shot = true
	deactive_laser()

func _physics_process(delta):
	var horizontal_distance = player.global_position.x - global_position.x
	var vertical_distance = player.global_position.y - global_position.y
		
	if health <= 0:
		enemy_state = "dead"
		velocity.y += gravity * delta
	elif abs(horizontal_distance) < horizontal_leeway and can_move:
		if (vertical_follow_distance - vertical_distance) > vertical_leeway:
			velocity.y -= 5
		elif (vertical_follow_distance - vertical_distance) < 0:
			velocity.y += 5
		else:
			velocity.y = 0
			enemy_state = "preparing_attack"
			if attack_timer.is_stopped():
				attack_timer.start(0.5)
			#attack
		velocity.x = 0
		#if can_move and abs(abs(vertical_distance) - vertical_follow_distance) < 30:
			
	elif abs(horizontal_distance) > horizontal_leeway and abs(horizontal_distance) < horizontal_follow_distance and can_move:
		enemy_state = "flying"
		var direction = sign(horizontal_distance)
		velocity.x = direction * speed
		if not attack_timer.is_stopped():
			attack_timer.stop()
	else:
		velocity.x = 0
		velocity.y = 0
		if enemy_state == "attacking" and attack_timer.is_stopped():
			
			attack_timer.start(3)
	move_and_slide()
	play_anim()

func play_anim():
	if enemy_state == "flying":
		$AnimatedSprite2D.play("idle")  
	elif enemy_state == "attacking":
		$AnimatedSprite2D.play("attack")
		shoot_projectile()
		if $laser_beam/AnimatedSprite2D.frame == 9:
			$laser_beam/CollisionShape2D.disabled = false
		elif $laser_beam/AnimatedSprite2D.frame == 18:
			$laser_beam/CollisionShape2D.set_deferred("disabled", true)
	elif enemy_state == "dead":
		$AnimatedSprite2D.play("death")
		await(get_tree().create_timer(1).timeout)
		var loot_scene = load("res://Scenes/loot.tscn")
		for i in randi_range(1, 5):
			var loot = loot_scene.instantiate()
			get_parent().add_child(loot)
			loot.global_position = global_position + Vector2(randi_range(-100, 100), randi_range(-100, 0))
		emit_signal("enemy_death")
		queue_free()

func _on_attack_timer_timeout():
	if enemy_state == "preparing_attack":
		enemy_state = "attacking"
		can_move = false
	elif enemy_state == "attacking":
		can_move = true
		enemy_state = "flying"
		deactive_laser()

func take_damage(att: String):
	$AnimationPlayer.play("hit")
	deactive_laser()
	var damage_popup = load("res://Scenes/damage_popup.tscn").instantiate()
	if att == "1":
		health -= 50
		damage_popup.start(50)
	if att == "2":
		health -= 25
		damage_popup.start(25)
	$hp.value = health
	damage_popup.scale *= 2
	add_child(damage_popup)
	damage_popup.global_position = global_position + Vector2(randi_range(-20, 20), randi_range(0, -200))
	
func shoot_projectile():
	activate_laser()
	
func activate_laser():
	$laser_beam/AnimatedSprite2D.visible = true
	$laser_beam/AnimatedSprite2D.play("laser")
	$laser_beam/PointLight2D.visible = true
func deactive_laser():
	$laser_beam/AnimatedSprite2D.visible = false
	$laser_beam/AnimatedSprite2D.stop()
	$laser_beam/CollisionShape2D.set_deferred("disabled", true)
	$laser_beam/PointLight2D.visible = false


func _on_laser_beam_body_entered(body):
	if body.is_in_group("player"):
		body.change_health(-50)

