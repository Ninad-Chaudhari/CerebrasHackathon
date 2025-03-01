extends CharacterBody2D

@export var speed : float = 50.0
@export var idle_time_range : Vector2 = Vector2(3, 7)  # Min and max idle time in seconds
@export var attack_damage : int = 20  # Boss attack damage
@export var health : int = 200  # Boss Health
@export var attack_cooldown : float = 2.0  # Time between attacks

@onready var animations = $Animations
@onready var health_bar : ProgressBar = $CollisionShape2D/ProgressBar

var is_attacking : bool = false
var is_dead : bool = false
var time_since_last_action : float = 0.0

func _ready():
	add_to_group("npc")
	health_bar.max_value = health
	health_bar.value = health
	start_idle()

func _physics_process(delta):
	if is_dead:
		return  # Stop processing if dead

	time_since_last_action += delta

	# If enough time has passed, perform a random action
	if time_since_last_action >= randf_range(idle_time_range.x, idle_time_range.y):
		perform_random_action()
		time_since_last_action = 0.0

# Function to randomly perform actions
func perform_random_action():
	print("Boss performing random action")
	if is_dead or is_attacking:
		return  # No actions if dead or mid-attack

	var action = randi() % 2  # 0 = idle, 1 = attack, 2 = hit
	match action:
		0:
			start_idle()
		1:
			attack()

# IDLE ANIMATION
func start_idle():
	if is_dead:
		return
	animations.play("Idle")
	print("Boss is idling.")

# ATTACK FUNCTION
func attack():
	if is_dead or is_attacking:
		return

	is_attacking = true
	animations.play("attack")
	print("Boss attacks!")
	await animations.animation_finished
	is_attacking = false
	start_idle()

# FUNCTION TO SIMULATE TAKING A HIT
func _on_hurt():
	if is_dead:
		return
	if animations.is_playing():
		animations.stop()
	animations.play("hit")
	print("Boss took a hit!")

# FUNCTION TO APPLY DAMAGE
func apply_damage(damage: int):
	if is_dead:
		return

	health -= damage
	health_bar.value = health
	print("Boss health: ", health)

	if health <= 0:
		die()

# DIE FUNCTION
func die():
	if is_dead:
		return
	
	is_dead = true
	animations.play("Die")
	print("Boss has died!")
	await animations.animation_finished
	queue_free()  # Remove boss after death animation
	
