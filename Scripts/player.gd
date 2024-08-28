extends CharacterBody2D

const SPEED = 700.0
const JUMP_VELOCITY = -700.0
const DASH_SPEED_MULTIPLIER = 2.0
const DASH_DURATION = 1.0 

var target_dash_speed = (SPEED * DASH_SPEED_MULTIPLIER)

var default_mask = 0b111
var rolling_mask = 0b011

var is_reloading_scene
var shield_held = false
var shield = 100
var attack_type: String = "1"
var mana = 100
var health = 1000
var coins = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_move = true
var can_attack = true
var UI
var jumps: int = 0

enum PlayerStates {IDLE, WALKING, ATTACKING, DASHING, JUMPING, DEAD}
var player_state = PlayerStates.IDLE
var direction

var computer 

@onready var dash_timer = Timer.new()
@onready var attack_timer = Timer.new()
@onready var regen_timer = Timer.new()

func _ready():
	$background.play()
	computer = get_node("computer_dialogue")
	computer.connect("dialogue_done", _on_dialogue_done)
	
	if Global11.get_current() == 0:
		can_attack = false
		can_move = false
		
	$animation.play("spawn")
	add_child(regen_timer)
	regen_timer.autostart = true
	regen_timer.wait_time = 1
	regen_timer.timeout.connect(_on_Reg_Timer_timeout)
	regen_timer.start()
	
	UI = get_node("UI")
	add_to_group("player")
	dash_timer.one_shot = true
	dash_timer.wait_time = 1
	add_child(dash_timer)
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	
	attack_timer.one_shot = true
	attack_timer.wait_time = 1
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	if is_reloading_scene:
		return
	
	velocity.x = 0
	if health > 0:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			jumps = 0
			velocity.y = 0
			if player_state == PlayerStates.JUMPING:
				$dust.play("land")
				if direction != 0:
					player_state = PlayerStates.WALKING
					play_animation(direction)
				#else:
					#player_state = PlayerStates.IDLE
					#$animation.play("idle")

		if player_state != PlayerStates.ATTACKING and player_state != PlayerStates.DASHING:
			handle_movement(delta)
		elif player_state == PlayerStates.DASHING:
			velocity.x += target_dash_speed * direction 
		if player_state == PlayerStates.IDLE or not is_on_floor():
			$dust.visible = false
		else:
			$dust.visible = true
		
		if Input.is_action_just_pressed("1"):
			attack_type = "1"
		if Input.is_action_just_pressed("2"):
			attack_type = "2"
		if Input.is_action_just_pressed("dash") and can_move and player_state != PlayerStates.DASHING and dash_timer.is_stopped():
			start_dash()
		if Input.is_action_pressed("shield"):
			shield_held = true
			can_move = false
			can_attack = false
			$animation.play("shield")
		if Input.is_action_just_released("shield"):
			$animation.play("idle")
			shield_held = false
			can_move = true
			can_attack = true
	elif player_state != PlayerStates.DEAD:
		velocity.y = 400
		player_state = PlayerStates.DEAD
		$animation.play("death")
		regen_timer.stop()
		$player_death.play()
		get_parent().get_node("AnimationPlayer").play("fade_out")
		await get_tree().create_timer(3).timeout
		is_reloading_scene = true
		call_deferred("reload_scene")
		
	move_and_slide()

func reload_scene():
	get_tree().reload_current_scene()

func handle_movement(delta):
	direction = Input.get_axis("left", "right")
	
	if global_position.x > get_global_mouse_position().x:
		$animation.flip_h = true
		#$dust.flip_h = true
	else:
		$animation.flip_h = false
		#$dust.flip_h = false
	#$animation.flip_h = direction < 0
	$dust.flip_h = direction < 0
	
	if direction != 0 and can_move:
		velocity.x = direction * SPEED
		if is_on_floor():
			player_state = PlayerStates.WALKING
			play_animation(direction)
	else:
		if player_state == PlayerStates.WALKING or player_state == PlayerStates.IDLE:
			player_state = PlayerStates.IDLE
			$animation.play("idle")

	if Input.is_action_just_pressed("ui_accept") and jumps < 2 and can_move:
		$jump.play()
		jumps += 1
		velocity.y = JUMP_VELOCITY
		$animation.play("jump-idle")
		player_state = PlayerStates.JUMPING
		# Implement double jump logic 
		
	if Input.is_action_just_pressed("attack") and can_attack:
		if (attack_type == "1" and mana >= 25) or (attack_type == "2" and mana >= 10):
			player_state == PlayerStates.ATTACKING
			can_attack = false
			attack_timer.start(0.5)
			var mouse_position = get_global_mouse_position()
			var attack_position
			if attack_type == "1":
				attack_position = $attack.global_position
			elif attack_type == "2":
				attack_position = $attack2.global_position
			
			var direction_to_mouse = (mouse_position - attack_position).normalized()
			var angle_to_mouse = atan2(direction_to_mouse.y, direction_to_mouse.x)
			
		
			if attack_type == "1":
				$attack.rotation = angle_to_mouse
				$attack.visible = true
				$attack/CollisionShape2D.disabled = false
				$attack/anim.play("lightning")
				change_mana(-25)
			if attack_type == "2":
				$attack2.rotation = angle_to_mouse
				$attack2.visible = true
				$attack2/CollisionShape2D.disabled = false
				$attack2/anim.play("zap")
				change_mana(-10)
		

func start_dash():
	player_state = PlayerStates.DASHING
	$animation.play("roll")  # Ensure this animation exists and is correct
	$dust.play("roll")
	#collision_mask = 0b011
	collision_layer = 32
	can_move = false
	dash_timer.start(DASH_DURATION)

func _on_dash_timer_timeout():
	player_state = PlayerStates.IDLE
	can_move = true
	#collision_mask = 0b111
	collision_layer = 2
	

func _on_attack_timer_timeout():
	can_attack = true
	$attack.visible = false
	$attack/CollisionShape2D.disabled = true
	$attack2.visible = false
	$attack2/CollisionShape2D.disabled = true

func change_health(dmg: int):
	if !shield_held:
		health += dmg
		if dmg < 0:
			$take_damage.play()
			$animation.modulate = Color(5000, 1, 1, 1)
			await get_tree().create_timer(0.3).timeout
			$animation.modulate = Color(1, 1, 1, 1)
	
	if health < 0:
		health = 0
	if health > 1000:
		health = 1000
	UI.update_health(health)

func change_mana(amt: int):
	mana += amt
	if mana < 0:
		mana = 0
	if mana > 100:
		mana = 100
	UI.update_mana(mana)
	
func change_coins(amt: int):
	$coin.play()
	coins += amt
	UI.update_coins(coins)
func play_animation(dir):
	if player_state == PlayerStates.WALKING:
		$animation.play("walk")
		$dust.play("run")

func _on_dialogue_done():
	can_move = true
	can_attack = true

func _on_attack_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(attack_type)
		change_mana(10)
		$give_damage.play()

func _on_attack_area_entered(area):
	if area.is_in_group("turret"):
		area.take_damage(attack_type)
		change_mana(10)
		$give_damage.play()

func _on_Reg_Timer_timeout():
	if health < 1000:
		health += 1
		UI.update_health(health)
	if mana < 100 and !shield_held:
		mana += 3
	if shield_held and mana > 5:
		mana -= 5
	UI.update_mana(mana)
