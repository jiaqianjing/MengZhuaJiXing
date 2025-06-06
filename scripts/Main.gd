extends Node2D

# Main game control script
# Manages game state, score, lives and star generation

# Preload star scenes
@export var star_scene: PackedScene = preload("res://scenes/Star.tscn")
@export var special_star_scene: PackedScene = preload("res://scenes/SpecialStar.tscn")

# Game state variables
var score: int = 0
var lives: int = 3
var game_over: bool = false

# Star generation related
var star_spawn_timer: float = 1.5
var min_spawn_time: float = 0.8
var spawn_time_decrease: float = 0.02

# UI node references
@onready var score_label = $UI/ScoreLabel
@onready var lives_label = $UI/LivesLabel
@onready var game_over_panel = $UI/GameOverPanel
@onready var star_spawner = $StarSpawner
@onready var player = $Player

# Audio node references
@onready var star_collect_sound = $AudioPlayers/StarCollectSound
@onready var special_star_sound = $AudioPlayers/SpecialStarSound
@onready var game_over_sound = $AudioPlayers/GameOverSound
@onready var background_music = $AudioPlayers/BackgroundMusic

func _ready():
	"""Game initialization"""
	print("Star Catcher game started!")
	update_ui()

	# Load audio files
	load_audio_files()

	# Connect player signals
	if player:
		player.star_collected.connect(_on_star_collected)
		player.life_lost.connect(_on_life_lost)

func load_audio_files():
	"""Load audio files"""
	var audio_loaded = true

	if star_collect_sound:
		var audio_resource = load("res://assets/sounds/star_collect.wav")
		if audio_resource:
			star_collect_sound.stream = audio_resource
		else:
			audio_loaded = false

	if special_star_sound:
		var audio_resource = load("res://assets/sounds/special_star.wav")
		if audio_resource:
			special_star_sound.stream = audio_resource
		else:
			audio_loaded = false

	if game_over_sound:
		var audio_resource = load("res://assets/sounds/game_over.wav")
		if audio_resource:
			game_over_sound.stream = audio_resource
		else:
			audio_loaded = false

	if background_music:
		var audio_resource = load("res://assets/music/background.wav")
		if audio_resource:
			background_music.stream = audio_resource
			background_music.volume_db = -10.0
			background_music.autoplay = true
			# Manually play background music to ensure it starts
			background_music.play()
			print("Background music started ")
		else:
			audio_loaded = false

	if audio_loaded:
		print("Audio files loaded successfully")
	else:
		print("Some audio files failed to load, game will run in silent mode")

func _on_star_spawner_timeout():
	"""Star spawner timeout callback - generate new stars"""
	if game_over:
		return

	spawn_star()

	# Gradually increase game difficulty
	if star_spawn_timer > min_spawn_time:
		star_spawn_timer -= spawn_time_decrease
		star_spawner.wait_time = star_spawn_timer

func spawn_star():
	"""Function to spawn stars"""
	# Randomly choose to spawn normal or special star (10% chance for special star)
	var star_instance
	if randf() < 0.1:
		star_instance = special_star_scene.instantiate()
	else:
		star_instance = star_scene.instantiate()

	# Set random horizontal position for star (adapted for portrait 480 width)
	var spawn_x = randf_range(50, 430)  # 480 - 50 = 430
	star_instance.position = Vector2(spawn_x, -50)

	# Connect star signals
	star_instance.star_missed.connect(_on_star_missed)

	# Add to scene
	add_child(star_instance)

func _on_star_collected(points: int):
	"""Callback when star is collected"""
	score += points
	update_ui()

	# Play sound effect
	if points == 50:  # Special star
		if special_star_sound and special_star_sound.stream:
			special_star_sound.play()
			print("Playing special star sound effect")
		else:
			print("Special star sound effect failed - audio node or stream is empty")
	else:  # Normal star
		if star_collect_sound and star_collect_sound.stream:
			star_collect_sound.play()
			print("Playing normal star sound effect")
		else:
			print("Normal star sound effect failed - audio node or stream is empty")

	print("Star collected! Earned ", points, " points")

func _on_life_lost():
	"""Callback when life is lost"""
	lives -= 1
	update_ui()
	print("Lost a life! Remaining lives: ", lives)

	if lives <= 0:
		end_game()

func _on_star_missed():
	"""Callback when star is missed"""
	lives -= 1
	update_ui()
	print("Missed star! Remaining lives: ", lives)

	if lives <= 0:
		end_game()

func update_ui():
	"""Update UI display"""
	if score_label:
		score_label.text = "Score: " + str(score)
	if lives_label:
		lives_label.text = "Lives: " + str(lives)

func end_game():
	"""Game over handling"""
	game_over = true
	star_spawner.stop()

	# Stop background music
	if background_music:
		background_music.stop()

	# Set audio player to not be affected by pause
	if game_over_sound and game_over_sound.stream:
		game_over_sound.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		game_over_sound.play()
		print("Playing game over sound effect")
	else:
		print("Game over sound effect failed - audio node or stream is empty")

	# Pause game (except UI)
	get_tree().paused = true

	# Set game over panel to not be affected by pause
	if game_over_panel:
		game_over_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		game_over_panel.visible = true

	print("Game over! Final score: ", score)

func clear_all_stars():
	"""Clear all stars in the scene"""
	# Get all child nodes
	for child in get_children():
		# Check if it's a star node (by group or script)
		if child.has_method("collect") or child.name.begins_with("Star") or child.name.begins_with("SpecialStar"):
			child.queue_free()

func _on_restart_button_pressed():
	"""Restart button callback"""
	print("Restarting game")
	# Cancel pause
	get_tree().paused = false
	# Reload scene
	get_tree().reload_current_scene()

func _on_tutorial_button_pressed():
	"""Tutorial button callback"""
	print("Showing tutorial")
	# Jump to tutorial scene
	get_tree().change_scene_to_file("res://scenes/Tutorial.tscn")
