extends Node2D

var messages = [
	"...", 
	" ", 
	"It's so great that you're here! ",
	"My defense systems have been overtaken by a nasty virus! ",
	"I was on the verge of losing everything, so I summoned you here. ",
	"Please repair my systems by killing this virus... it is currently residing deep within my drives...",
	" (Press Space to Continue)"
]

var messages2 = [
	"Inside the computer world you have the power of electricity!", 
	" ", 
	"Click anywhere on the screen to unleash one of two powerful electric attacks! Keep in mind you have limited mana! ",
	"The other controls are as follows: 'A' to move left, 'D' to move right, 'SPACE' to jump, 'R' to roll, 'E' to interact, and 'F' to shield! ",
	"(Press Space to Continue)"
]

var j = 0
var can_type = true
var finished = false
var displaying_first_set = true  # Add this to track which set of messages is being displayed

signal dialogue_done

func _ready():
	if Global11.get_current() == 0:
		visible = true
		can_type = true
	else:
		visible = false
		can_type = false

func _process(delta):
	if can_type and displaying_first_set:
		type_text(messages[j])
	elif can_type and !displaying_first_set:
		type_text(messages2[j])  # Use messages2 when displaying the second set
	elif finished and Input.is_action_just_pressed("ui_accept"):
		if displaying_first_set:
			$Label.text = ""  # Reset the label text
			j = 0  # Reset the index
			finished = false  # Reset the finished state
			can_type = true  # Allow typing to start again
			displaying_first_set = false  # Switch to the second set of messages
		else:
			emit_signal("dialogue_done")
			visible = false
			queue_free()

func type_text(text: String):
	can_type = false
	for i in range(text.length()):
		$Label.text += text[i]
		await(get_tree().create_timer(0.05).timeout)
	j += 1
	if displaying_first_set and j < messages.size():
		can_type = true
	elif not displaying_first_set and j < messages2.size():
		can_type = true
	else:   
		can_type = false
		finished = true

