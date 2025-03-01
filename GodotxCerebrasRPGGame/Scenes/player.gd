extends CharacterBody2D

@export var speed : float = 50.0
@export var attack_range : float = 50.0  # Attack range to trigger an attack on NPC
@export var push_force : float = 20.0  # Force to push the NPC back when attacked

# Declare variables for attack and chatting
var is_attacking : bool = false
var target_npc : CharacterBody2D = null

func _physics_process(delta):
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * speed
	print("Moving player",dir)
	move_and_slide()
	
	# Check for attack input (e.g., pressing 'Q' key)
	if Input.is_action_just_pressed("attack"):
		attack_nearby_npc()

	# Check for chat input (e.g., pressing 'F' key)
	#if Input.is_action_just_pressed("chat"):
		#initiate_chat()

# Function to attack NPCs in range
func attack_nearby_npc():
	# Check if there's an NPC nearby to attack
	var nearby_npcs = get_tree().get_nodes_in_group("npc")  # Assuming NPCs are in the "npc" group
	for npc in nearby_npcs:
		if global_position.distance_to(npc.global_position) <= attack_range:
			perform_attack(npc)
			break

# Function to perform the attack on the NPC
func perform_attack(npc: CharacterBody2D):
	if npc:
		print("Attacking NPC: ", npc.name)
		# Apply damage to the NPC (you can adjust this method as needed)
		npc.apply_damage(10)  # Example damage value
		
		# Push the NPC back after attack
		push_npc_back(npc)

# Function to push the NPC back
func push_npc_back(npc: CharacterBody2D):
	# Calculate the direction to push the NPC away from the player
	var direction = (npc.global_position - global_position).normalized()
	var push_vector = direction * push_force
	
	# Apply the push to the NPC's position
	npc.global_position += push_vector
	print("Pushed NPC back: ", npc.name)

# Function to initiate a chat with the NPC
func initiate_chat():
	if target_npc != null and global_position.distance_to(target_npc.global_position) <= attack_range:
		print("Initiating chat with NPC: ", target_npc.name)
		# Replace this with actual chat logic
		target_npc.talk_to_player()

# Helper function to find the closest NPC (if needed)
func get_closest_npc() -> CharacterBody2D:
	var nearby_npcs = get_tree().get_nodes_in_group("npc")
	var closest_npc : CharacterBody2D = null
	var closest_distance : float = attack_range
	
	for npc in nearby_npcs:
		var distance = global_position.distance_to(npc.global_position)
		if distance <= closest_distance:
			closest_npc = npc
			closest_distance = distance
	
	return closest_npc
