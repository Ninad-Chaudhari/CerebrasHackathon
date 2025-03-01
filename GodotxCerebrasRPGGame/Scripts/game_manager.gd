extends Node

#@onready var api_key : String = FileAccess.open("res://key.txt", FileAccess.READ).get_as_text()
var api_key : String = ""
var url : String = ""

@export var temperature : float = 0.5
var max_tokens : int = 1024
var headers = ["Content-type: application/json", "Authorization: Bearer " + api_key]
var model : String = "gpt-4o-mini"
var messages = []
var request : HTTPRequest

@onready var dialogue_box = get_node("/root/Main/CanvasLayer/DialogueBox")
var current_npc
@export_multiline var dialogue_rules : String

signal on_player_talk
signal on_npc_talk(npc_dialogue)

func _ready():
	print("Here's the text: " + api_key)
	request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", _on_request_completed)


func dialogue_request(player_dialogue):
	var prompt = player_dialogue
	
	if len(messages) == 0:
		var header_prompt = "Act as a " + current_npc.physical_description + " in a fantasy rpg."
		header_prompt += "As a character, you are " + current_npc.personality + ". "
		header_prompt += "Your location is " + current_npc.location_description + ". "
		header_prompt += "You have secret knowledge that you will not speak about unless asked by me: " + current_npc.secret_knowledge + ". However, sometimes you might accidentally let a hint slip about this secret knoweldge. "
		
		prompt = dialogue_rules + "\n" + header_prompt + "\nWhat is your first line of dialogue?"
		
	messages.append({
		"role": "user",
		"content": prompt
		})
		
	on_player_talk.emit()
	
	var body = JSON.new().stringify({
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"model": model
	})

	print("Headers : ", headers)
	print("URL : ",url)
	print("Body :",body)
	var send_request = request.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if send_request != OK:
		print("There was an error!")

func _on_request_completed(result, response_code, header, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print(response)
	var message = response["choices"][0]["message"]["content"]
	
	print(message)
	
	messages.append({
		"role": "system",
		"content": message
	})
	
	on_npc_talk.emit(message)

func enter_new_dialogue(npc):
	current_npc = npc
	messages = []
	dialogue_box.visible = true
	dialogue_box.initialize_with_npc(npc)
	dialogue_request("")
	
func exit_dialogue():
	current_npc = null
	messages = []
	dialogue_box.visible = false

func is_dialogue_active():
	return dialogue_box.visible
