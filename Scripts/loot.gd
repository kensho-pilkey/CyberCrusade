extends Area2D

enum items {COIN, HEALTH, MANA} 
#Stun Grenade / Grenade slot
var item_type = items.COIN

func _ready():
	add_to_group("item")
	scale = Vector2(0.1, 0.1)
	var num = randi_range(1, 3)
	if num == 1:
		item_type = items.COIN
	elif num == 2:
		item_type = items.HEALTH
	elif num == 3:
		item_type = items.MANA
	

func _process(_delta):
	if item_type == items.COIN:
		$AnimatedSprite2D.play("coin")
		$PointLight2D.color = "ffff00"
	elif item_type == items.HEALTH:
		$AnimatedSprite2D.play("health")
		$PointLight2D.color = "ff0000"
	elif item_type == items.MANA:
		$AnimatedSprite2D.play("mana")
		$PointLight2D.color = "0000ff"

func _on_body_entered(body):
	if body.is_in_group("player"):
		if item_type == items.COIN:
			body.change_coins(1)
		elif item_type == items.HEALTH:
			body.change_health(100)
			$health.play()
		elif item_type == items.MANA:
			body.change_mana(20)
			$mana.play()
		#add collection logic here
		visible = false
		await get_tree().create_timer(0.5).timeout
		queue_free()
