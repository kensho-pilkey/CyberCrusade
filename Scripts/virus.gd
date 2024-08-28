extends CharacterBody2D

var speed = 300
var player
var enemy_state = "idle"
var health = 200
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var detection_range = 1500
var charge_delay = 1.0 # Time to wait before charging
var attached_time = 1.0 # Time to stay attached
var can_move = true
var charge_target
var attack_timer = Timer.new()

var knockback_timer = Timer.new()
var in_knockback = false
var knockback_velocity = Vector2.ZERO

signal enemy_death

func _ready():
	add_child(knockback_timer)
	knockback_timer.timeout.connect(_on_knockback_timer_timeout)
	$hp.value = health
	player = get_parent().get_node("player")
	add_to_group("enemy")
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	var distance = player.global_position - global_position
	if in_knockback:
		velocity = knockback_velocity
		move_and_slide()
	else:
		if distance.length() < detection_range and enemy_state == "idle":
			enemy_state = "preparing"
			can_move = false
			attack_timer.start(charge_delay)
		elif enemy_state == "charging" and can_move:
			var charge_direction = (charge_target - global_position).normalized()
			velocity = charge_direction * speed * 6
			move_and_slide()
			attack_timer.start(charge_delay)
			await get_tree().create_timer(1.0).timeout
			if enemy_state != "attached":
				enemy_state = "idle"
		elif enemy_state == "attached" and can_move:
			global_position = player.global_position
	if health <= 0 and enemy_state != "dead":
		enemy_state = "dead"
		
	play_anim()

func _on_attack_timer_timeout():
	if enemy_state == "preparing":
		can_move = true
		enemy_state = "charging"
		charge_target = player.global_position
	if enemy_state == "attached":
		player.change_health(-50)
		enemy_state = "idle"
		$AnimationPlayer.play("RESET")

	#elif attached:
		#attached = false # Detach after 1 second
		#can_move = true
		#enemy_state = "idle"

func play_anim():
	match enemy_state:
		"idle":
			$AnimationPlayer.play("idle")
		"attached":
			$AnimationPlayer.play("attached")
		"charging":
			$AnimationPlayer.play("charge")
		"dead":
			$AnimationPlayer.play("death")
			await(get_tree().create_timer(1).timeout)
			var loot_scene = load("res://Scenes/loot.tscn")
			for i in randi_range(1, 5):
				var loot = loot_scene.instantiate()
				get_parent().add_child(loot)
				loot.global_position = global_position + Vector2(randi_range(-100, 100), randi_range(-100, 0))
			emit_signal("enemy_death")
			queue_free()

		
func take_damage(att: String):
	
	$AnimationPlayer2.play("hit")
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
	damage_popup.scale *= 4
	damage_popup.global_position = global_position + Vector2(randi_range(-20, 20), randi_range(0, -200))	


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		enemy_state = "attached"
		attack_timer.start(1)
	

func _on_knockback_timer_timeout():
	$AnimationPlayer.play("RESET")
	in_knockback = false
	knockback_velocity = Vector2.ZERO
	
func apply_knockback():
	var direction = (global_position - player.global_position).normalized()
	knockback_velocity = direction * 500
	in_knockback = true
	knockback_timer.start(0.5)
