extends CharacterBody2D
@export var speed = 30
@export var limit = 0.5

@export var endPoint: Marker2D
var startPosition
var endPosition

@onready var animations = $AnimatedSprite2D
func _ready():
	startPosition = position
	endPosition = endPoint.global_position
	

func changeDirection():
	var tempEnd = endPosition
	endPosition = startPosition
	startPosition = tempEnd

func updateAnimations():
	var animationString = "walkUp"
	if velocity.y>0:
		animationString = "walkDown"
	animations.play(animationString)
	
	
func updateVelocity():
	var moveDirection = (endPosition - position)
	if moveDirection.length()< limit:
		changeDirection()
	velocity = moveDirection.normalized()*speed	
		
func _physics_process(delta):
	updateVelocity()
	move_and_slide()	
	updateAnimations()
