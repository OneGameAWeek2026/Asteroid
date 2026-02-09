class_name Player extends CharacterBody2D

signal died

const ACCEL = 10.0
const MAX_SPEED = 500.0
const TURN_RATE = 250.0
const FIRE_RATE = 0.1

var screenSize
var shoot_cd = false
var canShoot = true
var canMove = true

var alive = true

@onready var barrel: Marker2D = $Barrel
@onready var laser_holder: Node2D = $"../LaserHolder"
@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"

const SHOT = preload("res://Prefabs/shot.tscn")
const SHOOT = preload("res://Sounds/Shoot.wav")

func _ready() -> void:
	screenSize = get_viewport_rect().size
	
func _process(_delta: float) -> void:
	if Input.is_action_pressed("fire") and canShoot and alive:
		if !shoot_cd:
			audio_stream_player.stream = SHOOT
			audio_stream_player.play()
			shoot_cd = true
			var laser = SHOT.instantiate()
			laser_holder.add_child(laser)
			laser.global_position = barrel.global_position
			laser.rotation = rotation
			await  get_tree().create_timer(FIRE_RATE).timeout
			shoot_cd = false

func _physics_process(delta: float) -> void:
	if not canMove or not alive:
		return
	
	
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

func die():
	if alive == true:
		alive = false
		emit_signal("died")
		get_child(0).hide()
		canMove = false
		canShoot = false
		velocity = Vector2.ZERO	
		$CollisionPolygon2D.set_deferred("disabled", true)
		
func respawn():
	if alive == false:
		canMove = true
		canShoot = true
		alive = true
		get_child(0).show()
		global_position = Vector2(screenSize.x/2,screenSize.y/2)
		$CollisionPolygon2D.set_deferred("disabled", false)
