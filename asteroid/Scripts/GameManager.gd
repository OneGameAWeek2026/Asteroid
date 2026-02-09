extends Node2D

var paused = false
var screenSize
var lives = 3:
	set(value):
		lives = value
		lives_label.text = "Lives: " + str(value)
var score = 0:
	set(value):
		score = value
		score_label.text = "Score: " + str(value)
		
@onready var player: Player = $Player
@onready var asteroid_holder: Node2D = $AsteroidHolder
@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var asteroid_timer: Timer = $AsteroidTimer
@onready var laser_holder: Node2D = $LaserHolder
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const ASTEROIDS = [preload("res://Prefabs/asteroid_small.tscn"),preload("res://Prefabs/asteroid_mid.tscn"),preload("res://Prefabs/asteroid_big.tscn")]
const DEATH = preload("res://Sounds/Death.wav")
const HIT = preload("res://Sounds/Hit.wav")
const SHOOT = preload("res://Sounds/Shoot.wav")
const EXPLODE = preload("res://Sounds/explode.wav")
const AUDIO_STREAM_PLAYER = preload("res://Prefabs/audio_stream_player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screenSize = get_viewport_rect().size
	score = 0
	player.connect("died", on_player_death)
	for x in asteroid_holder.get_children():
		x.connect("exploded",on_asteroid_exploded)

func on_asteroid_exploded(pos, size):
	var aud = AUDIO_STREAM_PLAYER.instantiate()
	add_child(aud)
	match size:
		0:
			score += 150
			return
		1: 
			score += 100
		2:
			score += 50
	for i in range(2):
		var a = ASTEROIDS[size - 1].instantiate()
		asteroid_holder.call_deferred("add_child",a)
		a.global_position = pos
		a.connect("exploded", on_asteroid_exploded)

func on_player_death():
	lives -= 1
	if lives == 0:
		audio_stream_player.stream = DEATH
		audio_stream_player.play()
		$GameOverScreen.show()
	else:
		audio_stream_player.stream = HIT
		audio_stream_player.play()
		player.global_position = Vector2(screenSize.x/2,screenSize.y/2)
		await get_tree().create_timer(1).timeout
		player.respawn()

func spawnAsteroid(pos, size):
	var a = ASTEROIDS[size - 1].instantiate()
	asteroid_holder.call_deferred("add_child",a)
	a.global_position = pos
	a.connect("exploded", on_asteroid_exploded)

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()

func pause():
	paused = true
	player.canMove = false
	player.canShoot = false
	for x in asteroid_holder.get_children():
		x.paused = 0
	for x in laser_holder.get_children():
		x.paused = 0
	asteroid_timer.paused = true
	
func unpause():
	paused = false
	player.canMove = true
	player.canShoot = true
	for x in asteroid_holder.get_children():
		x.paused = 1
	for x in laser_holder.get_children():
		x.paused = 1
	asteroid_timer.paused = false

func _on_asteroid_timer_timeout() -> void:
	if asteroid_timer.wait_time > 1:
		asteroid_timer.wait_time -= 0.1 
	
	match randi_range(0,3):
		0:
			spawnAsteroid(Vector2(randi_range(0,screenSize.x),0),randi_range(0,2))
		1:
			spawnAsteroid(Vector2(randi_range(0,screenSize.x),screenSize.y),randi_range(0,2))
		2:
			spawnAsteroid(Vector2(0,randi_range(0,screenSize.y)),randi_range(0,2))
		3:
			spawnAsteroid(Vector2(screenSize.y,randi_range(0,screenSize.y)),randi_range(0,2))
