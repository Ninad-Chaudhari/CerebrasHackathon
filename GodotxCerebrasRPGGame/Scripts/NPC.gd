extends CharacterBody2D

@export var icon : Texture
@export_multiline var physical_description : String
@export_multiline var location_description : String
@export_multiline var personality : String
@export_multiline var secret_knowledge : String
@export var speed : float = 50.0
@export var idle_time_range : Vector2 = Vector2(5, 10)  # Min and max idle time in seconds
@export var move_radius : float = 200.0  # NPC can move within this radius
@export var interaction_radius : float = 20.0  # How close the player must be to interact
@export var health : int = 100  # NPC Health
@onready var health_bar : ProgressBar = $CollisionShape2D/ProgressBar

var time_since_last_action : float = 0.0
var target_position : Vector2
var moving : bool = false
var combat_target : CharacterBody2D = null

func _ready():
	# Add the NPC to the "npc" group
	add_to_group("npc")
	
	# Set initial target position
	target_position = global_position
	health_bar.max_value = health
	health_bar.value = health
	
	# Set the progress bar's position 50 pixels below the NPC
	
func _physics_process(delta):
	time_since_last_action += delta
	
	# Handle autonomous movement if NPC isn't already moving
	if not moving:
		if time_since_last_action >= randf_range(idle_time_range.x, idle_time_range.y):
			perform_random_action()
			time_since_last_action = 0.0

	# Move NPC towards target position
	if moving:
		move_towards_target(delta)
	
	# Check if the NPC is near another NPC to engage in combat
	check_for_combat()


func perform_random_action():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_action_request_completed)

	var body = JSON.new().stringify({
		"npc": {
			"name": self.name,
			"physical_description": physical_description,
			"location_description": location_description,
			"personality": personality,
			"secret_knowledge": secret_knowledge,
			"health": health
		}
	})

	http_request.request("http://localhost:8000/get_random_action", headers, HTTPClient.METHOD_POST, body)

func _on_action_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print("NPC Action: ", response["npc_action"])


# Function to move NPC randomly within a defined radius
func move_randomly():
	moving = true
	target_position = global_position + Vector2(randf_range(-move_radius, move_radius), randf_range(-move_radius, move_radius))
	print("NPC moving to ", target_position)

# Function to move the NPC towards the target position
func move_towards_target(delta):
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# If NPC reaches the target position, stop moving
	if global_position.distance_to(target_position) < 5.0:
		moving = false
		print("NPC has arrived at the target position.")

# Function to make the NPC idle (doing nothing for a while)
func idle():
	moving = false
	print("NPC is idle.")

# Function to have the NPC talk to the player if they are close enough
func talk_to_player():
	if global_position.distance_to(get_player_position()) < interaction_radius:
		print("NPC says: 'Hello, adventurer!'")  # Replace with actual dialogue logic
		moving = false
	else:
		print("NPC is too far to talk.")

# Helper function to get the player's position (replace with your actual player reference)
func get_player_position() -> Vector2:
	var player = get_node_or_null("/root/Main/Player")  # Adjust path as needed
	if player:
		return player.global_position
	return Vector2.ZERO

# Function to check if NPCs are close to each other to start combat
func check_for_combat():
	if combat_target == null:  # Search for nearby NPCs to fight
		var nearby_npcs = get_tree().get_nodes_in_group("npc")
		for npc in nearby_npcs:
			if npc != self and global_position.distance_to(npc.global_position) < interaction_radius:
				engage_in_combat(npc)
				break

# Function to start combat with another NPC
func engage_in_combat(target_npc):
	if target_npc != null:
		combat_target = target_npc
		print("NPC engages in combat with ", combat_target)
		perform_combat_action(target_npc)

# Function to perform combat action (e.g., push or attack)
func perform_combat_action(target_npc):
	# Apply damage to the target NPC
	var damage = 10  # Example damage value, adjust as needed
	target_npc.apply_damage(damage)

	# Optionally, NPCs can push each other when they brawl (adjust velocity or position)
	var push_distance = 50  # Distance to push the other NPC
	var push_direction = (target_npc.global_position - global_position).normalized()
	target_npc.global_position += push_direction * push_distance

	# Reset combat target after a brief combat action
	await get_tree().create_timer(2).timeout  # Wait for 2 seconds before next action
	combat_target = null

# Function to apply damage to NPC and update health
func apply_damage(damage: int):
	health -= damage
	health = max(health, 0)  # Prevent health from going below 0
	print("NPC health: ", health)
	health_bar.value = health  # Update health bar

	if health <= 0:
		die()

# Function to handle NPC's death
func die():
	print("NPC has died!")
	queue_free()  # Remove NPC from the scene
