extends Area2D

func _ready():
	close_portal()
	
func set_red():
	$PointLight2D.color = "df0002"
	$PointLight2D.visible = true
	$AnimatedSprite2D.play("open")
func set_blue():
	$PointLight2D.color = "0015e4"
	$PointLight2D.visible = true
	$AnimatedSprite2D.play("open")
	$CollisionShape2D.disabled = false
func close_portal():
	$AnimatedSprite2D.play("closed")
	$PointLight2D.visible = false
	$CollisionShape2D.disabled = true
