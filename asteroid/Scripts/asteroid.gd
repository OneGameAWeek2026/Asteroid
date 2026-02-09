class_name Asteroid extends Area2D

signal exploded

@export var AsteroidSize : int

var movement_vector = Vector2(0, -1)
var speed
var rotationRate
var screenSize
var paused = 1

func _ready() -> void:
	screenSize = get_viewport_rect().size
	match AsteroidSize:
		0:
			speed = 500
			rotation = randf_range(0.1,2*PI)
		1:
			speed = 300
			rotation = randf_range(0.1,2*PI)
		2:
			speed = 100
			rotation = randf_range(0.1,2*PI)
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta * paused
	
	if global_position.y + 50< 0:
		global_position.y = screenSize.y + 50
	if global_position.y - 50 > screenSize.y:
		global_position.y = -50
	if global_position.x + 50 < 0:
		global_position.x = screenSize.x + 50
	if global_position.x - 50 > screenSize.x:
		global_position.x = -50

func explode():
	emit_signal("exploded",position,AsteroidSize)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
