extends Area2D

const SPEED = 1000

var paused = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position += Vector2(0,-1).rotated(rotation) * SPEED * delta * paused


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Asteroid:
		area.explode()
		queue_free()
