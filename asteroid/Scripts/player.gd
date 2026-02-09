extends CharacterBody2D


const ACCEL = 10.0
const MAX_SPEED = 500.0
const TURN_RATE = 250.0
const FIRE_RATE = 0.1

var screenSize
var shoot_cd = false

@onready var barrel: Marker2D = $Barrel
@onready var laser_holder: Node2D = $"../LaserHolder"

const SHOT = preload("res://Prefabs/shot.tscn")

func _ready() -> void:
	screenSize = get_viewport_rect().size
	
func _process(_delta: float) -> void:
	if Input.is_action_pressed("fire"):
		if !shoot_cd:
			shoot_cd = true
			var laser = SHOT.instantiate()
			laser_holder.add_child(laser)
			laser.global_position = barrel.global_position
			laser.rotation = rotation
			await  get_tree().create_timer(FIRE_RATE).timeout
			shoot_cd = false

func _physics_process(delta: float) -> void:
	
	var inputVector := Vector2(0,Input.get_axis("forward","back"))
	velocity += inputVector.rotated(rotation) * ACCEL
	velocity = velocity.limit_length(MAX_SPEED)
	
	if Input.is_action_pressed("turn right"):
		rotate(deg_to_rad(TURN_RATE * delta))
	if Input.is_action_pressed("turn left"):
		rotate(deg_to_rad(-TURN_RATE * delta))
	
	if inputVector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, ACCEL)
	move_and_slide()
	
	if global_position.y < 0:
		global_position.y = screenSize.y
	if global_position.y > screenSize.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screenSize.x
	if global_position.x > screenSize.x:
		global_position.x = 0
