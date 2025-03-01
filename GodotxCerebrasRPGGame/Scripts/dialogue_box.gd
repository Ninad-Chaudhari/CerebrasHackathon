extends Panel

@onready var game_manager = get_node("/root/Main/GameManager")

@onready var dialogue_text : RichTextLabel = get_node("DialogueText")
@onready var npc_icon : TextureRect = get_node("NPCIcon")
@onready var talk_input : TextEdit = get_node("PlayerTalkInput")
@onready var talk_button : Button = get_node("TalkButton")
@onready var leave_button : Button = get_node("LeaveButton")

func _ready():
	game_manager.on_player_talk.connect(_on_player_talk)
	game_manager.on_npc_talk.connect(_on_npc_talk)
	
func initialize_with_npc(npc):
	npc_icon.texture = npc.icon
	dialogue_text.text = ""
	talk_button.disabled = true
	

func _on_talk_button_pressed():
	game_manager.dialogue_request(talk_input.text)

func _on_leave_button_pressed():
	game_manager.exit_dialogue()

func _on_player_talk():
	talk_input.text = ""
	dialogue_text.text = "Hmmm..."
	talk_button.disabled = true
	
func _on_npc_talk(npc_dialogue):
	dialogue_text.text = npc_dialogue
	talk_button.disabled = false
