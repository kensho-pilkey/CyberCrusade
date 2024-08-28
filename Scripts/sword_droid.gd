extends CharacterBody2D  # Assuming CharacterBody2D should be KinematicBody2D

var speed = 600
var player
var enemy_state = "idle"
var health = 100
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var detection_range = 1500
var attack_range = 200
var attack_timer = Timer.new()
var attack_cooldown = Timer.new()
var can_move = true

var knockback_timer = Timer.new()
var in_knockback = false
var knockback_velocity = Vector2.ZERO

signal enemy_death

func _ready():
	add_child(knockback_timer)
	knockback_timer.timeout.connect(_on_knockback_timer_timeout)
	
	$hp.value = health
	player = get_parent().get_node("player")  # Ensure this is the correct path to the player node
	add_to_group("enemy")
	
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.wait_time = 1.0
	attack_timer.one_shot = true

	
	add_child(attack_cooldown)
	attack_cooldown.timeout.connect(_on_attack_timer_timeout)
	attack_cooldown.wait_time = 3.0
	attack_cooldown.one_shot = true
func _physics_process(delta):
	var distance_x = player.global_position.x - global_position.x
	velocity.y += gravity * delta  # Apply gravity

	if health <= 0:
		enemy_state = "dead"
	elif abs(distance_x) < detection_range:
		if can_move:
			enemy_state = "walking"
			# Determine direction based on player's position relative to enemy
			var direction
			if abs(distance_x) < 100.0:
				direction = sign(distance_x) * -1
			else:
				direction = sign(distance_x)
			velocity.x = direction * speed
			if abs(distance_x) < attack_range and attack_cooldown.is_stopped():
				velocity.x = 0
				enemy_state = "attacking"
				can_move = false
				attack_cooldown.start(3)
				attack_timer.start()
			elif not attack_cooldown.is_stopped():
				velocity.x /= 2
	else:
		enemy_state = "idle"
		velocity.x = 0
	if in_knockback:
		velocity = knockback_velocity

	move_and_slide()
	play_anim(distance_x)

func play_anim(distance_x):
	if enemy_state == "idle":
		$AnimatedSprite2D.play("idle")
	elif enemy_state == "walking":
		if distance_x < 0:
			$AnimatedSprite2D.flip_h = true
			$attack/CollisionPolygon2D.scale = Vector2(-1, -1)
		else:
			$AnimatedSprite2D.flip_h = false
			$attack/CollisionPolygon2D.scale = Vector2(1, 1)
		$AnimatedSprite2D.play("walk")  
	elif enemy_state == "attacking":
		$AnimatedSprite2D.play("attack")
		$attack/CollisionPolygon2D.disabled = false
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
	enemy_state = "idle"
	can_move = true
	$attack/CollisionPolygon2D.disabled = true

func take_damage(att: String):
	#$AnimatedSprite2D.play("hit")
	$AnimationPlayer.play("hit")
	apply_knockback()
	var damage_popup = load("res://Scenes/damage_popup.tscn").instantiate()
	if att == "1":
		health -= 50
		damage_popup.start(50)
	if att == "2":
		health -= 25
		damage_popup.start(25)
	$hp.value = health
	add_child(damage_popup)
	damage_popup.global_position = global_position + Vector2(randi_range(-20, 20), randi_range(0, -200))
	
	
func _on_attack_body_entered(body):
	if body.is_in_group("player"):
		body.change_health(-50)

func _on_knockback_timer_timeout():
	in_knockback = false
	knockback_velocity = Vector2.ZERO
	
func apply_knockback():
	var direction = (global_position - player.global_position).normalized()
	knockback_velocity = direction * 500
	in_knockback = true
	knockback_timer.start(0.5)
