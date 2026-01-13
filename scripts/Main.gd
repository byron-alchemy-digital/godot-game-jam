extends Node2D
## Main scene controller - handles game flow, UI updates, and scene management
##
## This script manages the main game loop, including:
## - Spawning the player and enemies
## - Updating UI elements
## - Handling pause and game over states

# References to UI elements
@onready var score_label: Label = $CanvasLayer/UI/ScoreLabel
@onready var pause_menu: ColorRect = $CanvasLayer/UI/PauseMenu
@onready var game_over_screen: ColorRect = $CanvasLayer/UI/GameOverScreen

# Player scene to instantiate
var player_scene: PackedScene = preload("res://scenes/Player.tscn")
var player: CharacterBody2D = null

# Game state
var is_paused: bool = false
var is_game_over: bool = false


func _ready() -> void:
	# TODO: Initialize game state
	# TODO: Spawn player at starting position
	# TODO: Initialize level/enemies
	# TODO: Start background music

	_spawn_player()
	_update_score_display()

	# Connect to GameManager signals
	if GameManager:
		GameManager.score_changed.connect(_on_score_changed)
		GameManager.game_over.connect(_on_game_over)


func _process(_delta: float) -> void:
	# Handle pause input
	if Input.is_action_just_pressed("pause") and not is_game_over:
		_toggle_pause()

	# Handle restart input when game over
	if is_game_over and Input.is_action_just_pressed("action"):
		_restart_game()


func _spawn_player() -> void:
	## Spawns the player at the starting position
	# TODO: Define spawn point (could be a Marker2D node)
	# TODO: Add spawn animation/effect

	player = player_scene.instantiate()
	player.position = Vector2(640, 360)  # Center of screen
	add_child(player)

	# Connect player signals
	# TODO: Connect player death signal
	# player.died.connect(_on_player_died)


func _toggle_pause() -> void:
	## Toggles the game pause state
	is_paused = not is_paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused

	# TODO: Pause/resume audio
	# TODO: Show/hide pause menu animations


func _update_score_display() -> void:
	## Updates the score UI
	score_label.text = "Score: %d" % GameManager.score


func _on_score_changed(new_score: int) -> void:
	## Called when score changes in GameManager
	score_label.text = "Score: %d" % new_score

	# TODO: Add score pop animation
	# TODO: Play score sound effect
	# TODO: Check for high score


func _on_game_over() -> void:
	## Called when the game ends
	is_game_over = true
	game_over_screen.visible = true

	# TODO: Stop gameplay
	# TODO: Play game over sound
	# TODO: Save high score
	# TODO: Show final stats


func _on_player_died() -> void:
	## Called when player dies
	# TODO: Decrease lives
	# TODO: Respawn or game over

	if GameManager.lives <= 0:
		GameManager.trigger_game_over()
	else:
		# Respawn player
		_spawn_player()


func _restart_game() -> void:
	## Restarts the game
	GameManager.reset_game()
	get_tree().reload_current_scene()


# =============================================================================
# GAME JAM HELPER FUNCTIONS
# =============================================================================

func spawn_enemy_at(position: Vector2) -> void:
	## TODO: Implement enemy spawning
	## var enemy = enemy_scene.instantiate()
	## enemy.position = position
	## add_child(enemy)
	pass


func spawn_collectible_at(position: Vector2) -> void:
	## TODO: Implement collectible spawning
	## var collectible = collectible_scene.instantiate()
	## collectible.position = position
	## add_child(collectible)
	pass


func shake_camera(intensity: float = 5.0, duration: float = 0.2) -> void:
	## TODO: Implement camera shake effect
	## Great for juice/game feel
	pass


func slow_motion(time_scale: float = 0.5, duration: float = 0.5) -> void:
	## TODO: Implement slow motion effect
	## Engine.time_scale = time_scale
	## await get_tree().create_timer(duration * time_scale).timeout
	## Engine.time_scale = 1.0
	pass
