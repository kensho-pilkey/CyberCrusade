extends Control

func _ready():
	update_mana(100)
	update_health(1000)
	update_coins(0)
	
func update_mana(val: int):
	$mana_bar.value = val
	$mana_bar/mana.text = str(val)+ " / 100"
	
	
func update_health(val: int):
	$health_bar.value = val
	$health_bar/mana.text = str(val)+ " / 1000"

func update_coins(val: int):
	$coin_bar/coin.text = "X " + str(val)


func _on_reset_pressed():
	get_tree().reload_current_scene()
