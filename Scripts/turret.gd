extends Area2D

enum States {CLOSE, OPEN, IDLE, SHOOT, DEAD, BROKEN, HIT}
var player
var state = States.CLOSE
var health = 150
var can_change = true
var direction

@onready var timer = Timer.new()

func _ready():
	player = get_parent().get_node("player")
	add_to_group("turret")
	
	$hp.value = health
	timer.one_shot = true
	timer.wait_time = 1  # Adjust as necessary for your game's feel
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func _process(delta):
	if state != States.BROKEN:
		direction = sign(player.global_position.x - global_position.x)
		var distance_x = abs(player.global_position.x - global_position.x)
		$AnimatedSprite2D.flip_h = (player.global_position.x - global_position.x) < 0
		if distance_x <= 1200 and distance_x > 1000 and state == States.CLOSE and can_change:
			state = States.OPEN
			can_change = false
			timer.start()
		elif distance_x <= 1000 and state == States.IDLE and can_change:
			state = States.SHOOT
			can_change = false
			timer.start()
		elif distance_x > 1200 and state != States.CLOSE and can_change:
			state = States.CLOSE
			can_change = false
			timer.start()
		
		if health <= 0 and state != States.DEAD:
			state = States.DEAD
			can_change = false
			play_anim()
			timer.start()  # Wait for death animation to finish before breaking
		
		play_anim()


func play_anim():
	match state:
		States.DEAD:
			$AnimatedSprite2D.play("death")
		States.OPEN:
			$AnimatedSprite2D.play("open")
		States.IDLE:
			$AnimatedSprite2D.play("idle")
		States.SHOOT:
			$AnimatedSprite2D.play("shoot")
		States.CLOSE:
			if $AnimatedSprite2D.animation != "close":
				$AnimatedSprite2D.play("close")

func _on_timer_timeout():
	if state == States.OPEN:
		state = States.IDLE
	elif state == States.DEAD:
		state = States.BROKEN
		$AnimatedSprite2D.play("broken")
		var loot_scene = load("res://Scenes/loot.tscn")
		for i in randi_range(1, 5):
			var loot = loot_scene.instantiate()
			get_parent().add_child(loot)
			loot.global_position = global_position + Vector2(randi_range(-100, 100), randi_range(-100, 0))
		
	elif state == States.HIT:
		state = States.IDLE
	can_change = true  # Allow state changes again after a timeout
	
func take_damage(s: String):
	if health > 0:
		$AnimatedSprite2D.play("hit")
		can_change = false
		state = States.HIT
		timer.start(1)
		
		var damage_popup = load("res://Scenes/damage_popup.tscn").instantiate()
		if s == "1":
			health -= 50
			damage_popup.start(50)
		if s == "2":
			health -= 25
			damage_popup.start(25)
		$hp.value = health
		add_child(damage_popup)
		damage_popup.global_position = global_position + Vector2(randi_range(-20, 20), randi_range(0, -200))

func shoot_projectile():
	var projectile_instance = preload("res://Scenes/laser_bullet.tscn").instantiate()
	var adjust
	if direction == 1:
		adjust = Vector2(120, -65)
	else:
		adjust = Vector2(-120, -65)
	
	projectile_instance.position = self.position + adjust
	projectile_instance.set_dir(Vector2((player.global_position.x - global_position.x), 0))
	# Add the projectile to the world
	get_parent().add_child(projectile_instance)
	#await get_tree().create_timer(5).timeout
	#projectile_instance.queue_free()
	
func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "shoot" and $AnimatedSprite2D.frame == 5:
		shoot_projectile() 
