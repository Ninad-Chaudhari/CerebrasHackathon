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
@export var attack_range : float = 20.0  # Attack range
@export var attack_damage : int = 10  # Attack damage
@export var push_force : float = 20.0  # Push force upon attack
@export var health : int = 100  # NPC Health
@onready var health_bar : ProgressBar = $CollisionShape2D/ProgressBar
@onready var animations = $Walk
@onready var hitEffect = $HitEffect
@onready var hurtTimer = $hurtTimer

var time_since_last_action : float = 0.0
var target_position : Vector2
var moving : bool = false
var combat_target : CharacterBody2D = null
var is_attacking : bool = false
var lastAnimDirection: String = "Down"

func updateWalkAnimation():
	if is_attacking: return  # Prevent animation change while attacking
	
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
		animations.play("move" + direction)
		lastAnimDirection = direction


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
	velocity = Vector2.ZERO  # Stop all movement
	print("NPC is idle.")



func _ready():
	add_to_group("npc")
	hitEffect.play("RESET")
	target_position = global_position
	health_bar.max_value = health
	health_bar.value = health

func _physics_process(delta):
	time_since_last_action += delta

	if not moving and not is_attacking:
		if time_since_last_action >= randf_range(idle_time_range.x, idle_time_range.y):
			perform_random_action()
			time_since_last_action = 0.0

	if moving and not is_attacking:
		move_towards_target(delta)

	updateWalkAnimation()
	check_for_combat()
	

func perform_random_action():
	# Randomly decide if NPC should move, talk, or idle
	var action = randi() % 3
	if action == 0:
		move_randomly()
	elif action == 1:
		talk_to_player()
	else:
		idle()

# Function to move NPC randomly within a defined radius
func move_randomly():
	moving = true
	target_position = global_position + Vector2(randf_range(-move_radius, move_radius), randf_range(-move_radius, move_radius))
	print("NPC moving to ", target_position)

	
func talk_to_player():
	if global_position.distance_to(get_player_position()) < interaction_radius:
		print("NPC says: 'Hello, adventurer!'")  # Replace with actual dialogue logic
		moving = false
	else:
		print("NPC is too far to talk.")
		
# Helper function to get the player's position (replace with your actual player reference)
func get_player_position() -> Vector2:
	var player = get_node_or_null("/root/Main/Hero_GreenNinja")  # Adjust path as needed
	if player:
		return player.global_position
	return Vector2.ZERO

#ATTACK=========================================================================================================================
# Function to check for combat and attack
func check_for_combat():
	if combat_target == null:
		var nearby_npcs = get_tree().get_nodes_in_group("npc")
		for npc in nearby_npcs:
			if npc != self and global_position.distance_to(npc.global_position) < attack_range:
				print(self.name + "distance to :"+npc.name+"  : ",global_position.distance_to(npc.global_position))
				engage_in_combat(npc)
				break




# Start combat
func engage_in_combat(target_npc):
	if target_npc != null:
		combat_target = target_npc
		print(self.name + " NPC engages in combat with ", combat_target)
		attack_target(target_npc)

# Attack function with animation
func attack_target(target):
	if is_attacking: return  # Prevent multiple attacks at once
	
	is_attacking = true
	animations.play("attack" + lastAnimDirection)
	await animations.animation_finished
	is_attacking = false
	
	if target != null and global_position.distance_to(target.global_position) <= attack_range:
		perform_attack(target)

# Function to deal damage and push the target
func perform_attack(target):
	if target:
		print(self.name + " NPC attacks: ", target.name)
		target.apply_damage(attack_damage)

		# Push target away
		var direction = (target.global_position - global_position).normalized()
		var push_vector = direction * push_force
		target._on_hurt()
		target.global_position += push_vector
		print("Pushed target back: ", target.name)

# Function to apply damage to NPC
func apply_damage(damage: int):
	health -= damage
	health = max(health, 0)
	print("NPC health: ", health)
	health_bar.value = health

	if health <= 0:
		die()

func _on_hurt():
	hitEffect.play("hurtBlink")
	hurtTimer.start()
	await hurtTimer.timeout
	hitEffect.play("RESET")

func die():
	print("NPC has died!")
	queue_free()
