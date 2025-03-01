extends Area2D

@onready var game_manager = get_node("/root/Main/GameManager")
var current_npc



func _on_body_entered(body):
	if body.is_in_group("NPC"):
		current_npc = body


func _on_body_exited(body):
	if current_npc == body:
		current_npc = null

func _input(event):
	if Input.is_key_pressed(KEY_F) and game_manager.is_dialogue_active() == false:
		print("Open dialogue box")
		print(current_npc)
		if current_npc != null:
			game_manager.enter_new_dialogue(current_npc)
